<?php

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'vendor/autoload.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Retrieve form data
    $first_name = $_POST['first_name'];
    $last_name = $_POST['last_name'];
    $email = $_POST['email'];
    $language = $_POST['language'];

    // Compose email message
    $message = "First Name: $first_name\n" .
        "Last Name: $last_name\n" .
        "Email: $email\n" .
        "Language: $language\n";

    // Send email
    $mail = new PHPMailer(true);

    try {
        $mail->isSMTP();
        $mail->Host       = 'smtp.stackmail.com';  // SMTP server address
        $mail->SMTPAuth   = true;
        $mail->Username   = 'pankaj@sofitgrow.com'; // SMTP username
        $mail->Password   = 'Us3c6c52b'; // SMTP password
        $mail->SMTPSecure = 'ssl';
        $mail->Port       = 465;

        $mail->setFrom('pankaj@sofitgrow.com', $first_name . " " . $last_name);
        $mail->addAddress('akashbiswas2499@gmail.com'); // Recipient's email address

        $mail->isHTML(false);
        $mail->Subject = $language;
        $mail->Body    = $message;

        $mail->send();
        echo "Email sent successfully.";
    } catch (Exception $e) {
        echo "Failed to send email. Error: {$mail->ErrorInfo}";
    }
} else {
    echo "Form not submitted.";
}
