import nodemailer from 'nodemailer';

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.MAIL_USER,
        pass: process.env.MAIL_PASS
    }
})

export const kirimEmailResetPassword = async (email, token) => {
    const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${token}`;

    await transporter.sendMail({
        from: `"Posyandu Digital" <${process.env.MAIL_USER}>`,
        to: email,
        subject: 'Reset Password Posyandu Digital',
        html: `
        <div style="font-family: Arial, sans-serif; max-width: 480px; margin: auto;" >
            <h2>Reset Password</h2>
            <p>Anda menerima email ini karena ada permintaan reset password untuk akun Anda.</p>
            <p>Klik tombol di bawah untuk membuat password baru:</p>
            <a href="${resetUrl}"
                style="background:#2563eb; color:white; padding:12px 24px;
                text-decoration:none; border-radius:6px; display:inline-block;">
                Reset Password
            </a>
            <p style="margin-top:16px; color:#666;">
                Link ini berlaku selama <strong>15 menit</strong>.
                Jika Anda tidak merasa meminta reset password, abaikan email ini.
            </p>
        </div>`
    })
}