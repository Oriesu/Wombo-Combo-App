import 'package:flutter/material.dart';

class PlayersMenuOverlay extends StatefulWidget {
  final List<String> players;
  final TextEditingController newPlayerNameController;
  final VoidCallback onAddPlayer;
  final Function(int) onRemovePlayer;
  final VoidCallback onHideMenu;
  final Color Function(int) getPlayerColor;

  const PlayersMenuOverlay({
    Key? key,
    required this.players,
    required this.newPlayerNameController,
    required this.onAddPlayer,
    required this.onRemovePlayer,
    required this.onHideMenu,
    required this.getPlayerColor,
  }) : super(key: key);

  @override
  State<PlayersMenuOverlay> createState() => _PlayersMenuOverlayState();
}

class _PlayersMenuOverlayState extends State<PlayersMenuOverlay> {
  final FocusNode _textFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Enfocar el campo de texto cuando se abre el menú
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFieldFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: GestureDetector(
        onTap: widget.onHideMenu,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevenir que el tap se propague
              child: Container(
                width: 400,
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: const Color(0xFF2a0044),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header - Estilo web
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Gestión de Jugadores',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFCC00),
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            onPressed: widget.onHideMenu,
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Sección para agregar jugador - Estilo web
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: widget.newPlayerNameController,
                                focusNode: _textFieldFocusNode,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Nombre del jugador',
                                  hintStyle: TextStyle(color: Colors.white54),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                                maxLength: 15,
                                onSubmitted: (_) => _addPlayer(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _addPlayer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00CCFF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor: const Color(0xFF00CCFF).withOpacity(0.4),
                              ),
                              child: const Text(
                                'Agregar',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Lista de jugadores actuales - Estilo web
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jugadores Actuales (${widget.players.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00CCFF),
                            ),
                          ),
                          const SizedBox(height: 15),
                          
                          if (widget.players.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'No hay jugadores',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SingleChildScrollView(
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: widget.players.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final player = entry.value;
                                      return _buildPlayerTag(index, player);
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Información adicional - Estilo web
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Los cambios se guardan automáticamente',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Mínimo 2 jugadores requeridos',
                            style: TextStyle(
                              color: Color(0xFFFF6B6B),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerTag(int index, String playerName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Círculo de color del jugador - Estilo web
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: widget.getPlayerColor(index),
              shape: BoxShape.circle,
            ),
          ),
          
          // Nombre del jugador
          Text(
            playerName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          
          // Botón eliminar (solo si hay más de 2 jugadores)
          if (widget.players.length > 2) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _removePlayer(index),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFFFF6B6B),
                  size: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _addPlayer() {
    final name = widget.newPlayerNameController.text.trim();
    if (name.isEmpty) {
      _showSnackBar('Por favor, ingresa un nombre');
      return;
    }
    
    if (widget.players.contains(name)) {
      _showSnackBar('Este nombre ya existe');
      return;
    }
    
    if (name.length > 15) {
      _showSnackBar('El nombre no puede tener más de 15 caracteres');
      return;
    }
    
    widget.onAddPlayer();
    // Limpiar el campo de texto después de agregar
    widget.newPlayerNameController.clear();
    // Mantener el foco en el campo de texto
    _textFieldFocusNode.requestFocus();
  }

  void _removePlayer(int index) {
    if (widget.players.length <= 2) {
      _showSnackBar('Mínimo 2 jugadores requeridos');
      return;
    }
    
    widget.onRemovePlayer(index);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}