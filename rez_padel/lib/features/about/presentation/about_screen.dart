import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        backgroundColor: AppColors.hotPink,
        elevation: 0,
        title: Text(
          'O nama',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Center(
              child: Image.asset(
                'assets/icon/padelspace_logo_nobg.png',
                height: 100,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Dobrodošli u Padel Space!',
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.hotPink,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Prvi i najmoderniji zatvoreni padel centar na Novom Beogradu. Igrajte tokom cele godine, bez obzira na vreme!',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            _buildDivider(),
            const SizedBox(height: 32),

            // O Padel Space Section
            _buildSectionTitle('O Padel Space'),
            const SizedBox(height: 16),
            Text(
              'Padel Space je premijer destinacija za padel u Srbiji. Sa 4 zatvorena terena izgrađena po svetskim standardima u saradnji sa Jubo Padel-om (25+ godina iskustva), nudimo vrhunsko iskustvo za sve nivoe igrača – od početnika do profesionalaca.',
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.9),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            _buildLocationHighlight(
              Icons.local_parking,
              'Prostran i bezbedan parking (50+ mesta)',
            ),
            _buildLocationHighlight(
              Icons.local_cafe,
              'Caffe bar za opuštanje pre i posle igre',
            ),
            _buildLocationHighlight(
              Icons.location_on,
              'Novi Beograd – lako dostupna lokacija',
            ),

            const SizedBox(height: 32),
            _buildDivider(),
            const SizedBox(height: 32),

            // Aplikacija Section
            _buildSectionTitle('Rezervišite lako preko aplikacije!'),
            const SizedBox(height: 20),
            _buildAppFeature(
              Icons.touch_app_rounded,
              'Instant rezervacije',
              'Rezerviši termin u par klikova, bilo gde i bilo kada.',
            ),
            _buildAppFeature(
              Icons.access_time_filled_rounded,
              '24/7 pristup',
              'Rezerviši termin kad god ti odgovara – aplikacija radi non-stop.',
            ),
            _buildAppFeature(
              Icons.notifications_active_rounded,
              'Automatska obaveštenja',
              'Dobijaj podsetnike o svojim rezervacijama.',
            ),
            _buildAppFeature(
              Icons.credit_card_rounded,
              'Brzo plaćanje',
              'Sigurno plaćanje direktno preko aplikacije.',
            ),
            _buildAppFeature(
              Icons.bar_chart_rounded,
              'Pratite svoju aktivnost',
              'Vidi svoje rezervacije, istoriju igara i omiljene termine.',
            ),
            _buildAppFeature(
              Icons.confirmation_number_rounded,
              'Ekskluzivne ponude',
              'Budi prvi koji će saznati za specijalne akcije i turnire.',
            ),

            const SizedBox(height: 32),
            _buildDivider(),
            const SizedBox(height: 32),

            // Adresa Section
            _buildSectionTitle('Adresa'),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(
                      44.834105521834175,
                      20.359217255455203,
                    ),
                    initialZoom: 14,
                    interactionOptions: InteractionOptions(
                      flags:
                          InteractiveFlag.pinchZoom |
                          InteractiveFlag.drag |
                          InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'rez_padel',
                    ),
                    const MarkerLayer(
                      markers: [
                        Marker(
                          width: 40,
                          height: 40,
                          point: LatLng(44.834105521834175, 20.359217255455203),
                          alignment: Alignment.topCenter,
                          child: Icon(
                            Icons.location_on,
                            color: AppColors.hotPink,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Autoput za Zagreb 20, Beograd, Srbija',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 32),
            _buildDivider(),
            const SizedBox(height: 32),

            // Info Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Radno vreme'),
                      const SizedBox(height: 4),
                      Text(
                        '09:00 - 23:00',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel('Kontakt'),
                      const SizedBox(height: 4),
                      Text(
                        '+381 65 69 88888',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.hotPink,
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.hotPink,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withOpacity(0.1), thickness: 1);
  }

  Widget _buildLocationHighlight(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.hotPink, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppFeature(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: AppColors.hotPink, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
