import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

/// Trò chơi ghép cặp: chạm 1 thẻ tiếng Anh và 1 thẻ nghĩa tiếng Việt tương ứng.
/// Ghép đúng -> 2 thẻ biến mất. Ghép sai -> rung nhẹ rồi bỏ chọn.
class MatchingGameScreen extends StatefulWidget {
  final List<Vocabulary> words;
  const MatchingGameScreen({super.key, required this.words});

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _CardItem {
  final String matchId; // id của Vocabulary, dùng để ghép cặp
  final String text;
  final bool isWord; // true = tiếng Anh, false = nghĩa tiếng Việt
  bool matched = false;
  _CardItem({required this.matchId, required this.text, required this.isWord});
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  late List<_CardItem> _cards;
  _CardItem? _firstPick;
  int _matchedPairs = 0;
  int _moves = 0;
  bool _locked = false;

  // Giới hạn tối đa 6 cặp mỗi lượt chơi để bàn chơi không quá rối
  static const int _maxPairs = 6;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    final pool = widget.words.take(_maxPairs).toList();
    final cards = <_CardItem>[];
    for (final v in pool) {
      cards.add(_CardItem(matchId: v.id, text: v.word, isWord: true));
      cards.add(_CardItem(matchId: v.id, text: v.meaning, isWord: false));
    }
    cards.shuffle();
    _cards = cards;
    _matchedPairs = 0;
    _moves = 0;
    _firstPick = null;
    _locked = false;
  }

  void _onTapCard(_CardItem card) {
    if (_locked || card.matched || card == _firstPick) return;

    setState(() {
      if (_firstPick == null) {
        _firstPick = card;
        return;
      }

      _moves++;
      if (_firstPick!.matchId == card.matchId) {
        _firstPick!.matched = true;
        card.matched = true;
        _matchedPairs++;
        _firstPick = null;
      } else {
        _locked = true;
        final wrongFirst = _firstPick;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          setState(() {
            _firstPick = null;
            _locked = false;
          });
        });
        _firstPick = wrongFirst; // giữ highlight đỏ trong lúc chờ
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalPairs = _cards.length ~/ 2;
    final done = _matchedPairs == totalPairs;

    return Scaffold(
      appBar: AppBar(title: const Text('Trò chơi ghép cặp')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: done
            ? _buildResult(totalPairs)
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Đã ghép: $_matchedPairs / $totalPairs', style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('Lượt chạm: $_moves', style: const TextStyle(color: AppColors.textGrey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: _cards.length,
                      itemBuilder: (context, i) {
                        final card = _cards[i];
                        return _buildCard(card);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCard(_CardItem card) {
    if (card.matched) {
      return const SizedBox.shrink();
    }
    final isWrongPair = _locked && card == _firstPick;
    final isSelected = card == _firstPick && !_locked;

    Color bg = card.isWord ? AppColors.blue.withOpacity(0.08) : AppColors.purple.withOpacity(0.08);
    Color border = card.isWord ? AppColors.blue : AppColors.purple;
    if (isSelected) {
      bg = (card.isWord ? AppColors.blue : AppColors.purple).withOpacity(0.25);
    }
    if (isWrongPair) {
      bg = AppColors.red.withOpacity(0.15);
      border = AppColors.red;
    }

    return GestureDetector(
      onTap: () => _onTapCard(card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 2),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          card.text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildResult(int totalPairs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('Hoàn thành $totalPairs cặp!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text('Bạn đã thực hiện $_moves lượt chạm', style: const TextStyle(color: AppColors.textGrey)),
          const SizedBox(height: 32),
          DuoButton(
            label: 'CHƠI LẠI',
            color: AppColors.purple,
            shadowColor: const Color(0xFFA557E0),
            onTap: () => setState(_setupGame),
          ),
        ],
      ),
    );
  }
}
