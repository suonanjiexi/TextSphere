import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:text_sphere_app/presentation/blocs/chat/chat_bloc.dart'; // Import ChatState
import 'package:text_sphere_app/presentation/widgets/app_avatar.dart'; // Assuming AppAvatar exists

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final ChatPartner? partner; // Pass partner for avatar in received messages

  const ChatMessageBubble({Key? key, required this.message, this.partner})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = message.isMe;
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final color =
        isMe ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant;
    final textColor =
        isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant;
    final avatarUrl =
        isMe ? null : partner?.avatarUrl; // Use partner avatar if not me

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment:
            CrossAxisAlignment.end, // Align avatar and bubble bottom
        children: [
          // Avatar for received messages
          if (!isMe && avatarUrl != null) ...[
            AppAvatar(imageUrl: avatarUrl, size: 36),
            SizedBox(width: 8.w),
          ],

          // Message bubble
          Flexible(
            // Allow bubble to shrink if needed
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              constraints: BoxConstraints(
                maxWidth: ScreenUtil().screenWidth * 0.7,
              ), // Max width constraint
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(18.r),
                  bottomLeft:
                      isMe ? Radius.circular(18.r) : Radius.circular(4.r),
                  bottomRight:
                      isMe ? Radius.circular(4.r) : Radius.circular(18.r),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: textColor,
                  height: 1.4,
                ),
              ),
            ),
          ),

          // Placeholder for sent messages' avatar (optional, usually not shown)
          // if (isMe) SizedBox(width: 44.w), // Matches avatar size + spacing
        ],
      ),
    );
  }
}
