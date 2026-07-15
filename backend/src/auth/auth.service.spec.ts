import 'dotenv/config';
import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { PrismaService } from '../prisma.service';
import { JwtService } from '@nestjs/jwt';
import { BadRequestException, UnauthorizedException } from '@nestjs/common';

describe('AuthService', () => {
  let service: AuthService;
  let prisma: PrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        PrismaService,
        {
          provide: JwtService,
          useValue: {
            sign: () => 'mock-jwt-token',
          },
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    prisma = module.get<PrismaService>(PrismaService);

    // Clean up database before each test to ensure test isolation
    await prisma.profile.deleteMany();
    await prisma.user.deleteMany();
    await prisma.verificationCode.deleteMany();
  });

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('should register a new user successfully', async () => {
    const username = 'testuser_' + Date.now();
    const result = await service.register({
      email: 'test@example.com',
      username,
      password: 'password123',
    });

    expect(result).toBeDefined();
    expect(result.email).toBe('test@example.com');
    expect(result.isVerified).toBe(false);

    // Check database entry
    const userInDb = await prisma.user.findUnique({
      where: { email: 'test@example.com' },
      include: { profile: true },
    });
    expect(userInDb).toBeDefined();
    expect(userInDb.profile.username).toBe(username);
  });

  it('should fail to register if email is already taken', async () => {
    const username1 = 'user1_' + Date.now();
    const username2 = 'user2_' + Date.now();

    await service.register({
      email: 'duplicate@example.com',
      username: username1,
      password: 'password123',
    });

    await expect(
      service.register({
        email: 'duplicate@example.com',
        username: username2,
        password: 'password123',
      }),
    ).rejects.toThrow(BadRequestException);
  });

  it('should login successfully with correct password', async () => {
    const username = 'loginuser_' + Date.now();
    await service.register({
      email: 'login@example.com',
      username,
      password: 'mypassword',
    });

    const result = await service.login({
      email: 'login@example.com',
      password: 'mypassword',
    });

    expect(result.accessToken).toBe('mock-jwt-token');
    expect(result.refreshToken).toBe('mock-jwt-token');
    expect(result.user.email).toBe('login@example.com');
  });

  it('should fail to login with incorrect password', async () => {
    const username = 'loginuser2_' + Date.now();
    await service.register({
      email: 'login2@example.com',
      username,
      password: 'mypassword',
    });

    await expect(
      service.login({
        email: 'login2@example.com',
        password: 'wrongpassword',
      }),
    ).rejects.toThrow(UnauthorizedException);
  });

  it('should generate and verify mock OTP code', async () => {
    const target = 'otp@example.com';
    const sendResult = await service.sendOtp({ target });
    expect(sendResult.success).toBe(true);

    // Verify it exists in db
    const otpInDb = await prisma.verificationCode.findUnique({ where: { target } });
    expect(otpInDb).toBeDefined();
    expect(otpInDb.code).toBe('1234');

    // Verify OTP
    const verifyResult = await service.verifyOtp({ target, code: '1234' });
    expect(verifyResult.success).toBe(true);

    // Check code was deleted
    const deletedOtp = await prisma.verificationCode.findUnique({ where: { target } });
    expect(deletedOtp).toBeNull();
  });
});
