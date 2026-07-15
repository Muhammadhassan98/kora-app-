import { Injectable, BadRequestException, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { SendOtpDto, VerifyOtpDto } from './dto/otp.dto';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    if (!dto.email && !dto.phoneNumber) {
      throw new BadRequestException('Provide either email or phone number');
    }

    // Check unique fields
    if (dto.email) {
      const existingEmail = await this.prisma.user.findUnique({ where: { email: dto.email } });
      if (existingEmail) throw new BadRequestException('Email already registered');
    }

    if (dto.phoneNumber) {
      const existingPhone = await this.prisma.user.findUnique({ where: { phoneNumber: dto.phoneNumber } });
      if (existingPhone) throw new BadRequestException('Phone number already registered');
    }

    const existingUsername = await this.prisma.profile.findUnique({ where: { username: dto.username } });
    if (existingUsername) throw new BadRequestException('Username already taken');

    // Hash password
    const passwordHash = await bcrypt.hash(dto.password, 10);

    // Create user and profile in a transaction
    const user = await this.prisma.$transaction(async (tx) => {
      const createdUser = await tx.user.create({
        data: {
          email: dto.email || null,
          phoneNumber: dto.phoneNumber || null,
          passwordHash,
          isVerified: false,
        },
      });

      await tx.profile.create({
        data: {
          userId: createdUser.id,
          username: dto.username,
          favoriteClub: dto.favoriteClub || null,
          interests: dto.interests || null,
        },
      });

      return createdUser;
    });

    return {
      id: user.id,
      email: user.email,
      phoneNumber: user.phoneNumber,
      isVerified: user.isVerified,
    };
  }

  async login(dto: LoginDto) {
    if (!dto.email && !dto.phoneNumber) {
      throw new BadRequestException('Provide either email or phone number to login');
    }

    // Find user
    const user = await this.prisma.user.findFirst({
      where: {
        OR: [
          ...(dto.email ? [{ email: dto.email }] : []),
          ...(dto.phoneNumber ? [{ phoneNumber: dto.phoneNumber }] : []),
        ],
      },
      include: { profile: true },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Compare passwords
    const passwordMatch = await bcrypt.compare(dto.password, user.passwordHash);
    if (!passwordMatch) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Generate tokens
    const payload = { sub: user.id, email: user.email, role: user.role };
    const accessToken = this.jwtService.sign(payload, { expiresIn: '1d' });
    const refreshToken = this.jwtService.sign(payload, { expiresIn: '7d' });

    return {
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        email: user.email,
        phoneNumber: user.phoneNumber,
        role: user.role,
        isVerified: user.isVerified,
        profile: user.profile,
      },
    };
  }

  async sendOtp(dto: SendOtpDto) {
    const code = '1234'; // Mock OTP for development
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes validity

    await this.prisma.verificationCode.upsert({
      where: { target: dto.target },
      update: { code, expiresAt },
      create: { target: dto.target, code, expiresAt },
    });

    console.log(`[OTP MOCK] Code ${code} sent to target: ${dto.target}`);

    return {
      success: true,
      message: `OTP sent successfully to ${dto.target}`,
    };
  }

  async verifyOtp(dto: VerifyOtpDto) {
    const verification = await this.prisma.verificationCode.findUnique({
      where: { target: dto.target },
    });

    if (!verification) {
      throw new BadRequestException('No verification code requested for this target');
    }

    if (verification.code !== dto.code) {
      throw new BadRequestException('Invalid OTP code');
    }

    if (new Date() > verification.expiresAt) {
      throw new BadRequestException('OTP code has expired');
    }

    // Update user as verified
    await this.prisma.user.updateMany({
      where: {
        OR: [
          { email: dto.target },
          { phoneNumber: dto.target },
        ],
      },
      data: { isVerified: true },
    });

    // Clean up verification code
    await this.prisma.verificationCode.delete({
      where: { target: dto.target },
    });

    return {
      success: true,
      message: 'OTP verified successfully and account activated',
    };
  }
}
