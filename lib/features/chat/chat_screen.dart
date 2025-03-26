import 'package:flutter/material.dart';
import 'package:kenz_chat/theme.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../../anim/wave_animation.dart';
import 'features/chat/chat_page.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  String activeTab = 'chats';
  String searchTerm = '';
  bool _expanded = false;
  final TextEditingController _inputController = TextEditingController();
  late AnimationController _iconAnimationController;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _iconAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_iconAnimationController);
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _iconAnimationController.forward();
      } else {
        _iconAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_ai_gradient.jpg'),
            fit: BoxFit.cover,
          ),
        ),

        // return Container(
    //   // Add gradient background container
    //   decoration: const BoxDecoration(
    //     gradient: LinearGradient(
    //       begin: Alignment.topCenter,
    //       end: Alignment.bottomCenter,
    //       colors: [
    //         Color(0xFF192150), // Dark purple from HomeScreen
    //         Color(0xFF390962), // Original background color
    //       ],
    //     ),
    //   ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: null,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Aligns everything to the left
            children: [
              // Kenverse Text
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    // Container(
                    //   height: 60, // Reduced height
                    //   child: Stack(
                    //     alignment: Alignment.centerLeft,
                    //     // Changed to left alignment
                    //     children: [
                    //       // Background animation - positioned to the left
                    //       Positioned(
                    //         left: -8,
                    //         top: 14,
                    //         child: SizedBox(
                    //           height: 60,
                    //           // Reduced height
                    //           width: 140,
                    //           // Reduced width to just cover the text
                    //           child: WaveAnimation(
                    //             height: 60,
                    //             width: 120,
                    //             primaryColor: Color(0xFF8A3FFC),
                    //             secondaryColor: Color(0xFF9949DC),
                    //             opacity: 0.8, // Slightly reduced opacity
                    //           ),
                    //         ),
                    //       ),
                    //
                    //       Padding(
                    //         padding: const EdgeInsets.symmetric(horizontal: 0),
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           children: [
                    //             Padding(
                    //               padding: const EdgeInsets.only(left: 16.0),
                    //               child: Text(
                    //                 'TKENNEKT',
                    //                 style: TextStyle(
                    //                   fontSize: 18,
                    //                   fontWeight: FontWeight.w600,
                    //                   letterSpacing: 0.5,
                    //                   color: AppColors.zinc_four,
                    //                 ),
                    //               ),
                    //             ),
                    //             Row(
                    //               children: [
                    //                 Icon(
                    //                   Icons.notifications_outlined,
                    //                   color: Color(0xFF71717A),
                    //                   size: 22,
                    //                 ),
                    //                 SizedBox(width: 16),
                    //                 Icon(
                    //                   Icons.more_vert,
                    //                   color: Color(0xFF71717A),
                    //                   size: 22,
                    //                 ),
                    //               ],
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    //
                    // // AI Assistant - Collapsible
                    // Container(
                    //   margin: const EdgeInsets.only(bottom: 16.0),
                    //   decoration: BoxDecoration(
                    //     color: const Color(0xFF111827), // gray-900
                    //     borderRadius: BorderRadius.circular(12),
                    //     border: Border.all(
                    //       color: _expanded ? const Color(0xFF1F2937) : Colors.transparent, // gray-800
                    //     ),
                    //     boxShadow: _expanded
                    //         ? [BoxShadow(
                    //       color: Colors.black.withOpacity(0.2),
                    //       blurRadius: 8,
                    //       offset: const Offset(0, 2),
                    //     )]
                    //         : null,
                    //   ),
                    //   child: Column(
                    //     children: [
                    //       // Header - Always visible
                    //       InkWell(
                    //         onTap: _toggleExpanded,
                    //         borderRadius: BorderRadius.circular(12),
                    //         child: Padding(
                    //           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    //           child: Row(
                    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //             children: [
                    //               Row(
                    //                 children: [
                    //                   // AI Icon with glow
                    //                   Container(
                    //                     height: 50,
                    //                     width: 50,
                    //                     decoration: BoxDecoration(
                    //                       borderRadius: BorderRadius.circular(8),
                    //                       color: Colors.black26,
                    //                     ),
                    //                     child: Stack(
                    //                       children: [
                    //                         // Glow effect
                    //                         Positioned.fill(
                    //                           child: Container(
                    //                             decoration: BoxDecoration(
                    //                               borderRadius: BorderRadius.circular(8),
                    //                               boxShadow: [
                    //                                 BoxShadow(
                    //                                   color: Colors.blue[500]!.withOpacity(0.2),
                    //                                   blurRadius: 8,
                    //                                   spreadRadius: -2,
                    //                                 ),
                    //                               ],
                    //                             ),
                    //                           ),
                    //                         ),
                    //                         // Icon
                    //                         Center(
                    //                           child: Icon(
                    //                             Icons.nightlight_round,
                    //                             color: Colors.blue[400],
                    //                             size: 24,
                    //                           ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   ),
                    //                   const SizedBox(width: 12),
                    //                   Column(
                    //                     crossAxisAlignment: CrossAxisAlignment.start,
                    //                     children: [
                    //                       const Text(
                    //                         'AI Companion',
                    //                         style: TextStyle(
                    //                           color: Colors.white,
                    //                           fontSize: 15,
                    //                           fontWeight: FontWeight.w500,
                    //                         ),
                    //                       ),
                    //                       Text(
                    //                         'Chat assistance',
                    //                         style: TextStyle(
                    //                           color: Colors.blue[300],
                    //                           fontSize: 13,
                    //                           fontWeight: FontWeight.w300,
                    //                           height: 1.2,
                    //                         ),
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ],
                    //               ),
                    //               Row(
                    //                 children: [
                    //                   Text(
                    //                     'Tap to chat',
                    //                     style: TextStyle(
                    //                       color: Colors.grey[400],
                    //                       fontSize: 12,
                    //                       fontWeight: FontWeight.w300,
                    //                     ),
                    //                   ),
                    //                   const SizedBox(width: 12),
                    //                   RotationTransition(
                    //                     turns: _iconAnimation,
                    //                     child: Icon(
                    //                       Icons.keyboard_arrow_down,
                    //                       color: Colors.grey[400],
                    //                       size: 18,
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //
                    //       // Expandable content
                    //       if (_expanded)
                    //         Padding(
                    //           padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                    //           child: Column(
                    //             children: [
                    //               const SizedBox(height: 8),
                    //               // Input field and send button
                    //               Row(
                    //                 children: [
                    //                   // Input field
                    //                   Expanded(
                    //                     child: Container(
                    //                       height: 50,
                    //                       decoration: BoxDecoration(
                    //                         color: const Color(0xFF1F2937), // gray-800
                    //                         borderRadius: const BorderRadius.only(
                    //                           topLeft: Radius.circular(8),
                    //                           bottomLeft: Radius.circular(8),
                    //                         ),
                    //                         border: Border.all(
                    //                           color: const Color(0xFF374151), // gray-700
                    //                         ),
                    //                       ),
                    //                       child: TextField(
                    //                         controller: _inputController,
                    //                         style: const TextStyle(color: Colors.white),
                    //                         decoration: const InputDecoration(
                    //                           contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                    //                           hintText: 'Ask me anything...',
                    //                           hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                    //                           border: InputBorder.none,
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   // Send button
                    //                   Container(
                    //                     height: 50,
                    //                     width: 56,
                    //                     decoration: BoxDecoration(
                    //                       borderRadius: const BorderRadius.only(
                    //                         topRight: Radius.circular(8),
                    //                         bottomRight: Radius.circular(8),
                    //                       ),
                    //                       gradient: LinearGradient(
                    //                         colors: [
                    //                           Colors.blue[600]!,
                    //                           Colors.blue[500]!,
                    //                         ],
                    //                         begin: Alignment.centerLeft,
                    //                         end: Alignment.centerRight,
                    //                       ),
                    //                       boxShadow: [
                    //                         BoxShadow(
                    //                           color: Colors.blue[800]!.withOpacity(0.3),
                    //                           blurRadius: 4,
                    //                           offset: const Offset(0, 2),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                     child: Material(
                    //                       color: Colors.transparent,
                    //                       child: InkWell(
                    //                         onTap: () {
                    //                           // Handle send
                    //                         },
                    //                         borderRadius: const BorderRadius.only(
                    //                           topRight: Radius.circular(8),
                    //                           bottomRight: Radius.circular(8),
                    //                         ),
                    //                         child: const Center(
                    //                           child: Icon(
                    //                             Icons.arrow_forward,
                    //                             color: Colors.white,
                    //                             size: 20,
                    //                           ),
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //
                    //               // Action buttons
                    //               Padding(
                    //                 padding: const EdgeInsets.only(top: 12.0),
                    //                 child: Row(
                    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //                   children: [
                    //                     Row(
                    //                       children: [
                    //                         // Voice button
                    //                         Container(
                    //                           decoration: BoxDecoration(
                    //                             color: const Color(0xFF1F2937), // gray-800
                    //                             borderRadius: BorderRadius.circular(8),
                    //                           ),
                    //                           child: Material(
                    //                             color: Colors.transparent,
                    //                             child: InkWell(
                    //                               onTap: () {},
                    //                               borderRadius: BorderRadius.circular(8),
                    //                               child: Padding(
                    //                                 padding: const EdgeInsets.all(8.0),
                    //                                 child: Icon(
                    //                                   Icons.mic,
                    //                                   color: Colors.grey[400],
                    //                                   size: 18,
                    //                                 ),
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         ),
                    //                         const SizedBox(width: 8),
                    //                         // Record button
                    //                         Container(
                    //                           decoration: BoxDecoration(
                    //                             color: const Color(0xFF1F2937), // gray-800
                    //                             borderRadius: BorderRadius.circular(8),
                    //                           ),
                    //                           child: Material(
                    //                             color: Colors.transparent,
                    //                             child: InkWell(
                    //                               onTap: () {},
                    //                               borderRadius: BorderRadius.circular(8),
                    //                               child: Padding(
                    //                                 padding: const EdgeInsets.all(8.0),
                    //                                 child: Icon(
                    //                                   Icons.radio_button_checked,
                    //                                   color: Colors.grey[400],
                    //                                   size: 18,
                    //                                 ),
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                     // Examples
                    //                     Text(
                    //                       'Examples: "Latest AI trends 2025"',
                    //                       style: TextStyle(
                    //                         color: Colors.grey[500],
                    //                         fontSize: 12,
                    //                       ),
                    //                     )
                    //                   ],
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //     ],
                    //   ),
                    // ),
                    //
                    //
                    //
                    SizedBox(height: 2),
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 0,
                      ),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color:Color(0x52636D9F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchTerm = value;
                            });
                          },
                          style: TextStyle(color: AppColors.zinc_four),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                            prefixIcon: Icon(
                              Icons.search,
                              color:Color(0x52EEF3FF),
                              size: 18,
                            ),
                            hintText: 'Search',
                            hintStyle: TextStyle(color:Color(0x52EEF3FF),),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFF27272A), // zinc-800
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildTab('Chats', 'chats'),
                      SizedBox(width: 24),
                      _buildTab('Groups', 'groups'),
                      SizedBox(width: 24),
                      _buildTab('Calls', 'calls'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),

        floatingActionButton: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Handle new chat creation
            },
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: Icon(Icons.chat, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title, String tabId) {
    final isActive = activeTab == tabId;
    return GestureDetector(
      onTap: () {
        setState(() {
          activeTab = tabId;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Color(0xFFF4F4F5) : Colors.transparent,
              // zinc-50
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color:
                isActive
                    ? Color(0xFFF4F4F5)
                    : Color(0xFF71717A), // zinc-50 : zinc-500
          ),
        ),
      ),
    );
  }
}
