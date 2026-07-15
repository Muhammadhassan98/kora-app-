import { IsNotEmpty, IsString, IsEnum, IsInt, Min } from 'class-validator';

export class CreatePredictionDto {
  @IsNotEmpty()
  @IsString()
  matchId: string;

  @IsNotEmpty()
  @IsEnum(['home', 'away', 'draw'])
  predictedWinner: string;

  @IsNotEmpty()
  @IsInt()
  @Min(0)
  predictedHomeScore: number;

  @IsNotEmpty()
  @IsInt()
  @Min(0)
  predictedAwayScore: number;
}
