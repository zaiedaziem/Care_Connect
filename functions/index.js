const functions = require("firebase-functions");
const admin = require("firebase-admin");
const sgMail = require("@sendgrid/mail");

admin.initializeApp();
sgMail.setApiKey(functions.config().sendgrid.key);

exports.sendAppointmentConfirmationEmail = functions.firestore
    .document("appointments/{appointmentId}")
    .onUpdate(async (change, context) => {
        const before = change.before.data();
        const after = change.after.data();

        // Only send email if status changed to 'confirmed'
        if (before.status !== "confirmed" && after.status === "confirmed") {
            const email = after.patientEmail;
            const patientName = after.patientName;
            const doctorName = after.doctorName;
            const date = after.date;
            const time = after.time;

            const msg = {
                to: email,
                from: "dsyafiq36@gmail.com", // Use your verified sender
                subject: "Appointment Confirmed",
                text:
                    "Dear " + patientName +
                    ", your appointment with Dr. " + doctorName +
                    " on " + date + " at " + time +
                    " has been confirmed. Thank you for booking with us!",
            };

            await sgMail.send(msg);
        }

        return null;
    });
