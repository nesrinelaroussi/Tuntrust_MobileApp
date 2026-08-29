import { IsEmail, IsNotEmpty } from 'class-validator';

export class LoginDto {
  @IsEmail({}, { message: 'Veuillez saisir une adresse e-mail valide.' })
  @IsNotEmpty()
  email: string;

  @IsNotEmpty()
  password: string;
}
