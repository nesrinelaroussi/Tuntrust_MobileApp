import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';

@Injectable()
export class MailService {
  private readonly logger = new Logger(MailService.name);
  private transporter: nodemailer.Transporter | null = null;

  constructor(private readonly configService: ConfigService) {
    const host = this.configService.get<string>('SMTP_HOST');
    const port = this.configService.get<number>('SMTP_PORT');
    const user = this.configService.get<string>('SMTP_USER');
    const pass = this.configService.get<string>('SMTP_PASS');

    // Only create transporter if credentials are provided
    if (host && port && user && pass) {
      this.transporter = nodemailer.createTransport({
        host,
        port,
        secure: port === 465, // true for 465, false for other ports
        auth: {
          user,
          pass,
        },
      });
      this.logger.log('SMTP Mail Transporter initialized successfully.');
    } else {
      this.logger.warn(
        'SMTP configuration is missing. Mailer will run in MOCK mode (printing OTPs to terminal).',
      );
    }
  }

  async sendOtpEmail(toEmail: string, userName: string, otpCode: string): Promise<void> {
    const from = this.configService.get<string>('SMTP_FROM') || '"TunTrust Identity" <no-reply@tuntrust.gov.tn>';
    const subject = 'Code de vérification TunTrust Mobile ID';

    const htmlContent = `
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Vérification de votre compte - TunTrust</title>
  <style>
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background-color: #f4f7f5;
      margin: 0;
      padding: 0;
      -webkit-font-smoothing: antialiased;
    }
    .wrapper {
      width: 100%;
      background-color: #f4f7f5;
      padding: 40px 0;
    }
    .container {
      max-width: 600px;
      margin: 0 auto;
      background-color: #ffffff;
      border-radius: 16px;
      overflow: hidden;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    }
    .header {
      background: linear-gradient(135deg, #05b257 0%, #007a87 100%);
      padding: 30px 20px;
      text-align: center;
    }
    .header h1 {
      color: #ffffff;
      margin: 0;
      font-size: 24px;
      font-weight: 700;
      letter-spacing: 0.5px;
    }
    .content {
      padding: 40px 30px;
      color: #333333;
      line-height: 1.6;
    }
    .content h2 {
      font-size: 20px;
      font-weight: 600;
      color: #111111;
      margin-top: 0;
      margin-bottom: 20px;
    }
    .content p {
      margin: 0 0 20px 0;
      font-size: 15px;
      color: #555555;
    }
    .otp-card {
      background-color: #f0faf4;
      border: 1px solid #d2f0dd;
      border-radius: 12px;
      padding: 24px;
      text-align: center;
      margin: 30px 0;
    }
    .otp-code {
      font-family: 'Courier New', Courier, monospace;
      font-size: 36px;
      font-weight: bold;
      color: #05b257;
      letter-spacing: 12px;
      margin: 0;
      padding-left: 12px; /* balance the letter spacing */
    }
    .footer {
      background-color: #fafbfc;
      border-top: 1px solid #eaecef;
      padding: 24px 30px;
      text-align: center;
    }
    .footer p {
      margin: 0 0 8px 0;
      font-size: 12px;
      color: #888888;
    }
    .footer a {
      color: #05b257;
      text-decoration: none;
    }
  </style>
</head>
<body>
  <div class="wrapper">
    <div class="container">
      <div class="header">
        <h1>TunTrust Mobile ID</h1>
      </div>
      <div class="content">
        <h2>Vérification de votre compte</h2>
        <p>Bonjour <strong>${userName}</strong>,</p>
        <p>Merci de vous être inscrit sur l'application <strong>TunTrust Mobile ID</strong>. Pour activer et sécuriser votre identité numérique, veuillez saisir le code de vérification à 4 chiffres ci-dessous dans l'application :</p>
        
        <div class="otp-card">
          <div class="otp-code">${otpCode}</div>
        </div>
        
        <p>Ce code est strictement confidentiel et reste valide pendant <strong>10 minutes</strong>. Ne le partagez avec personne.</p>
        <p>Si vous n'êtes pas à l'origine de cette demande, vous pouvez ignorer cet e-mail en toute sécurité.</p>
      </div>
      <div class="footer">
        <p>© 2026 TunTrust - Agence Nationale de Certification Électronique</p>
        <p>Technopole El Ghazala, Ariana, Tunisie | <a href="https://www.tuntrust.gov.tn" target="_blank">www.tuntrust.gov.tn</a></p>
      </div>
    </div>
  </div>
</body>
</html>
`;

    if (this.transporter) {
      try {
        await this.transporter.sendMail({
          from,
          to: toEmail,
          subject,
          html: htmlContent,
        });
        this.logger.log(`Verification email successfully sent to ${toEmail}`);
      } catch (err) {
        this.logger.error(`Failed to send verification email to ${toEmail}`, err);
        throw err;
      }
    } else {
      // Mock mode: Log OTP clearly to console
      console.log('\n============================================================');
      console.log(`[MOCK EMAIL] Verification Email Sent to: ${toEmail}`);
      console.log(`User Name: ${userName}`);
      console.log(`OTP Code: ${otpCode}`);
      console.log('------------------------------------------------------------');
      console.log('HTML Body Preview (First 200 chars):', htmlContent.replace(/\s+/g, ' ').substring(0, 200) + '...');
      console.log('============================================================\n');
    }
  }
}
