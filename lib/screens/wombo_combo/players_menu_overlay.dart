import 'package:flutter/material.dart';

class PlayersMenuOverlay extends StatefulWidget {
  final List<String> players;
  final TextEditingController newPlayerNameController;
  final VoidCallback onAddPlayer;
  final Function(int) onRemovePlayer;
  final VoidCallback onHideMenu;
  final Color Function(int) getPlayerColor;
  final String Function(int) getPlayerIconPath; // Nueva función para obtener la ruta del icono

  const PlayersMenuOverlay({
    Key? key,
    required this.players,
    required this.newPlayerNameController,
    required this.onAddPlayer,
    required this.onRemovePlayer,
    required this.onHideMenu,
    required this.getPlayerColor,
    required this.getPlayerIconPath, // Nuevo parámetro
  }) : super(key: key);

  @override
  State<PlayersMenuOverlay> createState() => _PlayersMenuOverlayState();
}

class _PlayersMenuOverlayState extends State<PlayersMenuOverlay> {
  final FocusNode _textFieldFocusNode = FocusNode();
  final TextEditingController _localTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _localTextController.text = widget.newPlayerNameController.text;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFieldFocusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(PlayersMenuOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.newPlayerNameController != widget.newPlayerNameController) {
      _localTextController.text = widget.newPlayerNameController.text;
    }
  }

  @override
  void dispose() {
    _textFieldFocusNode.dispose();
    _localTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.85),
      child: GestureDetector(
        onTap: widget.onHideMenu,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: 400,
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF2a0044),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF29B6F6), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF29B6F6).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Gestión de Jugadores',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFCC00),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: widget.onHideMenu,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(8),
                            minimumSize: const Size(40, 40),
                            shape: const CircleBorder(),
                          ),
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),

                    // Sección para agregar jugador
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                         Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: TextField(
                                  controller: _localTextController,
                                  focusNode: _textFieldFocusNode,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    height: 1.0,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Nombre del jugador',
                                    hintStyle: TextStyle(color: Colors.white54),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                    isDense: true,
                                  ),
                                  textAlignVertical: TextAlignVertical.center,
                                  maxLength: 15,
                                  onChanged: (value) {
                                    widget.newPlayerNameController.text = value;
                                  },
                                  onSubmitted: (_) => _addPlayer(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _addPlayer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00CCFF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(100, 50),
                            ),
                            child: const Text(
                              'Agregar',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Lista de jugadores actuales
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
                                color: Colors.white.withValues(alpha: 0.05),
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
                                  color: Colors.white.withValues(alpha: 0.05),
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
                    
                    // Información adicional
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Los cambios se guardan automáticamente',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.players.length >= 2 
                                ? '${widget.players.length} jugadores listos'
                                : 'Mínimo 2 jugadores requeridos',
                            style: TextStyle(
                              color: widget.players.length >= 2 
                                  ? const Color(0xFF00CC55)
                                  : const Color(0xFFFF6B6B),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono del jugador (sin forma circular)
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 10),
            child: Image.asset(
              widget.getPlayerIconPath(index),
              width: 24,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 24,
                  height: 24,
                  color: widget.getPlayerColor(index),
                );
              },
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
          
          // Botón eliminar 
          if (widget.players.length > 2) ...[
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _removePlayer(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: const Color(0xFFFF6B6B),
                padding: const EdgeInsets.all(4),
                minimumSize: const Size(30, 30),
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.close, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  void _addPlayer() {
    final name = _localTextController.text.trim();
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
    
    _localTextController.clear();
    widget.newPlayerNameController.clear();
    
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