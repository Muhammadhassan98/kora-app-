import { IsString, IsOptional, IsEmail, MinLength } from 'class-validator';

export class RegisterDto {
  @IsEmail()
  @IsOptional()
  email?: string;

  @IsString()
  @IsOptional()
  phoneNumber?: string;

  @IsString()
  @MinLength(6, { message: 'Password must be at least 6 characters long' })
  password: string;

  @IsString()
  username: string;

  @IsString()
  @IsOptional()
  favoriteClub?: string;

  @IsString()
  @IsOptional()
  interests?: string;
}
