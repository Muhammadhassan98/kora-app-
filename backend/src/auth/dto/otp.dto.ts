import { IsString, MinLength } from 'class-validator';

export class SendOtpDto {
  @IsString()
  target: string; // email or phone number
}

export class VerifyOtpDto {
  @IsString()
  target: string;

  @IsString()
  @MinLength(4, { message: 'OTP code must be at least 4 digits' })
  code: string;
}
