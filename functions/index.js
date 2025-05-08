const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

exports.notifyStatusChange = onDocumentUpdated("reservations/{reservationId}", async (event) => {
  const beforeSnap = event.data.before;
  const afterSnap = event.data.after;

  if (!beforeSnap.exists || !afterSnap.exists) return;

  const before = beforeSnap.data();
  const after = afterSnap.data();

  const beforeStatus = before?.status;
  const afterStatus = after?.status;
  const userId = after?.userId;

  if (beforeStatus !== afterStatus && userId) {
    await admin.firestore().collection("notifications").add({
      userId: userId,
      message: `Trạng thái đơn đặt chỗ của bạn đã chuyển thành: ${afterStatus}`,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`✅ Ghi thông báo cho user ${userId}: ${afterStatus}`);
  }
});
