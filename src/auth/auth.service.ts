import {
  BadRequestException,
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { UserService } from '../user/user.service';
import { MailService } from '../mail/mail.service';
import { SignupDto } from './dto/signup.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly userService: UserService,
    private readonly jwtService: JwtService,
    private readonly mailService: MailService,
  ) {}

  private generateOtp(): string {
    return Math.floor(1000 + Math.random() * 9000).toString();
  }

  async signup(dto: SignupDto) {
    const existing = await this.userService.findByEmail(dto.email);
    if (existing) {
      throw new ConflictException('Un compte avec cet e-mail existe déjà.');
    }

    const hashedPassword = await bcrypt.hash(dto.password, 10);
    const otp = this.generateOtp();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    const user = await this.userService.create({
      name: dto.name,
      email: dto.email,
      password: hashedPassword,
      otp,
      otpExpires,
      isActive: false,
    });

    await this.mailService.sendOtpEmail(user.email, user.name, otp);

    return {
      message: `Un code de vérification a été envoyé à ${user.email}. Vérifiez votre boîte mail ou la console du serveur.`,
      userId: (user as any)._id.toString(),
    };
  }

  async verifyOtp(userId: string, otp: string) {
    const user = await this.userService.findById(userId);
    if (!user) {
      throw new BadRequestException('Utilisateur introuvable.');
    }
    if (user.isActive) {
      return { message: 'Compte déjà activé. Vous pouvez vous connecter.' };
    }
    if (!user.otp || user.otp !== otp) {
      throw new BadRequestException('Code de vérification incorrect.');
    }
    if (!user.otpExpires || user.otpExpires < new Date()) {
      throw new BadRequestException('Le code de vérification a expiré. Veuillez en demander un nouveau.');
    }

    await this.userService.activateUser((user as any)._id.toString());

    return { message: 'Compte vérifié avec succès ! Vous pouvez maintenant vous connecter.' };
  }

  async resendOtp(userId: string) {
    const user = await this.userService.findById(userId);
    if (!user) {
      throw new BadRequestException('Utilisateur introuvable.');
    }
    if (user.isActive) {
      throw new BadRequestException('Ce compte est déjà activé.');
    }

    const otp = this.generateOtp();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000);
    await this.userService.updateOtp((user as any)._id.toString(), otp, otpExpires);
    await this.mailService.sendOtpEmail(user.email, user.name, otp);

    return { message: 'Un nouveau code de vérification a été envoyé.' };
  }

  async login(dto: LoginDto) {
    const user = await this.userService.findByEmail(dto.email);
    if (!user) {
      throw new UnauthorizedException('E-mail ou mot de passe incorrect.');
    }

    const isPasswordValid = await bcrypt.compare(dto.password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('E-mail ou mot de passe incorrect.');
    }

    if (!user.isActive) {
      throw new UnauthorizedException(
        'Votre compte n\'est pas encore vérifié. Vérifiez votre e-mail pour le code OTP.',
      );
    }

    const payload = {
      sub: (user as any)._id.toString(),
      email: user.email,
      name: user.name,
    };

    const token = this.jwtService.sign(payload);

    return {
      access_token: token,
      user: {
        id: (user as any)._id.toString(),
        name: user.name,
        email: user.email,
      },
    };
  }

  async getProfile(userId: string) {
    const user = await this.userService.findById(userId);
    if (!user) {
      throw new UnauthorizedException('Utilisateur introuvable.');
    }
    return {
      id: (user as any)._id.toString(),
      name: user.name,
      email: user.email,
      isActive: user.isActive,
    };
  }

  async forgotPassword(email: string) {
    const user = await this.userService.findByEmail(email);
    if (!user) {
      // Don't reveal if the email exists or not (security best practice)
      throw new BadRequestException('Aucun compte associé à cet e-mail.');
    }

    const otp = this.generateOtp();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes
    await this.userService.updateOtp((user as any)._id.toString(), otp, otpExpires);
    await this.mailService.sendOtpEmail(user.email, user.name, otp);

    return {
      message: 'Un code de réinitialisation a été envoyé.',
      userId: (user as any)._id.toString(),
    };
  }

  async resetPassword(userId: string, otp: string, newPassword: string) {
    const user = await this.userService.findById(userId);
    if (!user) {
      throw new BadRequestException('Utilisateur introuvable.');
    }
    if (!user.otp || user.otp !== otp) {
      throw new BadRequestException('Code de vérification incorrect.');
    }
    if (!user.otpExpires || user.otpExpires < new Date()) {
      throw new BadRequestException('Le code a expiré. Veuillez en demander un nouveau.');
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await this.userService.updatePassword((user as any)._id.toString(), hashedPassword);

    return { message: 'Mot de passe réinitialisé avec succès !' };
  }
}
