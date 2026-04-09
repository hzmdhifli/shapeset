import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/program.dart';
import '../../models/mock_data.dart';
import '../../widgets/athlete_card.dart';
import '../../widgets/special_program_card.dart';
import '../../services/localization_service.dart';
import '../../main.dart'; // For SettingsProvider if needed
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearchActive = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.toLowerCase();
    // Main legends for the grid
    final programs = mockPrograms.where((p) {
      if (query.isEmpty) return true;
      final matchName = p.name.toLowerCase().contains(query);
      final matchStyle = p.style.toLowerCase().contains(query);
      final matchTags = p.tags.any((tag) => tag.toLowerCase().contains(query));
      return matchName || matchStyle || matchTags;
    }).toList();

    // Archetypes for the special section
    final archetypes = mockFemalePrograms.where((p) {
      if (query.isEmpty) return true;
      final matchName = p.name.toLowerCase().contains(query);
      return matchName;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 38),
                _buildHero(),
                const SizedBox(height: 32),
                if (_searchQuery.isEmpty) ...[
                  _buildSectionTitle('Female special program', true),
                  const SizedBox(height: 18),
                  _buildArchetypeScroll(),
                  const SizedBox(height: 38),
                  _buildSectionTitle('LEGENDARY ATHLETES', false),
                  const SizedBox(height: 16),
                ],
                programs.isEmpty 
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Text(L10n.s(context, 'no_athletes'), style: const TextStyle(color: AppColors.muted)),
                        ),
                      )
                    : _buildAthleteGrid(programs),
                const SizedBox(height: 100), // Bottom nav space
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: _isSearchActive
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: AppColors.text, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: L10n.s(context, 'search_hint'),
                      hintStyle: const TextStyle(color: AppColors.muted),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: const BorderSide(color: AppColors.border2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: const BorderSide(color: AppColors.border2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: const BorderSide(color: AppColors.gold),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSearchActive = false;
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border2),
                    ),
                    child: const Icon(Icons.close, color: AppColors.muted, size: 16),
                  ),
                ),
              ],
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      L10n.s(context, 'home_title'),
                      style: GoogleFonts.bebasNeue(
                        fontSize: 22,
                        letterSpacing: 2,
                        color: AppColors.gold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSearchActive = true;
                        });
                      },
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border2),
                        ),
                        child: const Icon(Icons.search, color: AppColors.muted, size: 16),
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  'assets/images/widgi.png',
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(height: 32),
                ),
              ],
            ),
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            L10n.s(context, 'hero_category'),
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: AppColors.gold,
              letterSpacing: 2.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            L10n.s(context, 'hero_title'),
            style: GoogleFonts.bebasNeue(
              fontSize: 38,
              letterSpacing: 3,
              height: 1,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            L10n.s(context, 'hero_subtitle'),
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.muted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArchetypeScroll() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        scrollDirection: Axis.horizontal,
        itemCount: mockFemalePrograms.length,
        itemBuilder: (context, index) {
          final program = mockFemalePrograms[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
              width: 280,
              child: SpecialProgramCard(
                program: program,
                title: program.name,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isSpecial) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: isSpecial ? const Color(0xFFE1F5EE) : AppColors.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: isSpecial ? const Color(0xFFE1F5EE) : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAthleteGrid(List<Program> programs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: programs.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3 / 4,
        ),
        itemBuilder: (context, index) {
          return AthleteCard(program: programs[index]);
        },
      ),
    );
  }
}

