import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Text _title(String text) => Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      );

  Text _sectionTitle(String text) => Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      );

  Text _body(String text) => Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white70,
          height: 1.5,
        ),
      );

  Widget _spacer([double h = 16]) => SizedBox(height: h);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        backgroundColor: AppColors.hotPink,
        elevation: 0,
        title: Text(
          'Politika privatnosti',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title('Politika Privatnosti'),
            _spacer(8),
            _body('Poslednje ažuriranje: 6. decembar 2025.'),
            _spacer(24),
            _sectionTitle('1. Uvod'),
            _spacer(8),
            _body(
              'Rez Padel ("mi", "naš" ili "aplikacija") je softversko rešenje za upravljanje rezervacijama padel terena koje omogućava korisnicima da rezervišu termine putem mobilne aplikacije. Ova Politika privatnosti objašnjava kako prikupljamo, koristimo, čuvamo i štitimo vaše lične podatke kada koristite našu aplikaciju.\n\n'
              'Rez Padel pruža softversko rešenje padel centrima kao što je Padel Space, koji su nezavisni operateri i kontrolori podataka svojih korisnika. Mi kao pružaoci softverskog rešenja postupamo kao obrađivači podataka u ime padel centara.',
            ),
            _spacer(24),
            _sectionTitle('2. Kontrolor i Obrađivač Podataka'),
            _spacer(8),
            _body(
              'Kontrolor podataka: Padel centar koji koristite (npr. Padel Space) je kontrolor vaših ličnih podataka i određuje svrhe i načine obrade.\n\n'
              'Obrađivač podataka: Rez Padel je obrađivač podataka koji obrađuje vaše lične podatke u ime i po uputstvima padel centra.\n\n'
              'Za pitanja o obradi vaših podataka, možete kontaktirati:\n'
              '- Vaš padel centar direktno za pitanja o vašim podacima\n'
              '- Rez Padel putem [kontakt email] za tehnička pitanja o aplikaciji',
            ),
            _spacer(24),
            _sectionTitle('3. Podaci Koje Prikupljamo'),
            _spacer(8),
            _sectionTitle('3.1 Podaci koje Vi dostavljate:'),
            _spacer(4),
            _body(
              '- Osnovni podaci za registraciju: Ime, prezime, email adresa, broj telefona\n'
              '- Podaci o rezervacijama: Datum i vreme rezervacija, izabrani tereni, tip rezervacije\n'
              '- Podaci o plaćanju: Informacije o transakcijama (obrada plaćanja vrši se preko bezbednih trećih strana - ne čuvamo podatke o karticama)\n'
              '- Komunikacija: Poruke poslate preko aplikacije ili email komunikacija sa podrškom',
            ),
            _spacer(12),
            _sectionTitle('3.2 Automatski prikupljeni podaci:'),
            _spacer(4),
            _body(
              '- Tehnički podaci: Tip uređaja, operativni sistem, verzija aplikacije\n'
              '- Podaci o upotrebi: Interakcije sa aplikacijom, vreme pristupa, učestalost korišćenja\n'
              '- Podaci o lokaciji: Približna lokacija na osnovu IP adrese (ne prikupljamo preciznu GPS lokaciju)',
            ),
            _spacer(24),
            _sectionTitle('4. Kako Koristimo Vaše Podatke'),
            _spacer(8),
            _body(
              'Vaše lične podatke koristimo za sledeće svrhe:\n\n'
              '- Pružanje usluge: Omogućavanje rezervacije terena, upravljanje vašim nalogom, obrada plaćanja\n'
              '- Komunikacija: Slanje potvrda rezervacija, obaveštenja, odgovora na upite\n'
              '- Poboljšanje usluge: Analiza korišćenja aplikacije radi poboljšanja funkcionalnosti\n'
              '- Bezbednost: Zaštita od zloupotrebe, prevara i neovlašćenog pristupa\n'
              '- Marketing: Slanje promocija i obaveštenja o ponudama (samo uz vašu saglasnost)\n'
              '- Pravne obaveze: Ispunjavanje zakonskih i regulatornih zahteva',
            ),
            _spacer(24),
            _sectionTitle('5. Pravni Osnov za Obradu'),
            _spacer(8),
            _body(
              'Vaše podatke obrađujemo na osnovu:\n\n'
              '- Izvršenje ugovora: Za pružanje usluge rezervacije terena\n'
              '- Saglasnost: Za marketing komunikaciju i opcione funkcionalnosti\n'
              '- Legitimni interesi: Za poboljšanje usluge, bezbednost i analitiku\n'
              '- Pravne obaveze: Za ispunjavanje zakonskih zahteva',
            ),
            _spacer(24),
            _sectionTitle('6. Deljenje Podataka'),
            _spacer(8),
            _sectionTitle('6.1 Sa padel centrom:'),
            _spacer(4),
            _body(
              'Svi podaci o vašim rezervacijama i korišćenju usluga dostupni su padel centru čije usluge koristite.',
            ),
            _spacer(12),
            _sectionTitle('6.2 Sa pružaocima usluga:'),
            _spacer(4),
            _body(
              '- Supabase: Hosting baze podataka, autentifikacija i storage (serveri u EU)\n'
              '- Provajderi plaćanja: Za obradu transakcija (u skladu sa PCI DSS standardima)\n'
              '- Analitički servisi: Za analizu korišćenja aplikacije (anonimizovani podaci)',
            ),
            _spacer(12),
            _sectionTitle('6.3 Po zakonskoj obavezi:'),
            _spacer(4),
            _body(
              'Možemo otkriti vaše podatke ako je to potrebno radi:\n'
              '- Ispunjavanja zakonskih obaveza\n'
              '- Zaštite prava, imovine ili bezbednosti Rez Padel, korisnika ili javnosti\n'
              '- Istrage mogućih prekršaja\n\n'
              'Ne prodajemo vaše lične podatke trećim stranama.',
            ),
            _spacer(24),
            _sectionTitle('7. Međunarodni Transferi Podataka'),
            _spacer(8),
            _body(
              'Vaši podaci se čuvaju i obrađuju na serverima unutar Evropske unije. U slučaju prenosa podataka izvan EU, obezbeđujemo odgovarajuće zaštitne mere u skladu sa GDPR-om, uključujući:\n'
              '- Standardne ugovorne klauzule odobrene od strane Evropske komisije\n'
              '- Sertifikacije i mehanizme kao što su Privacy Shield (tamo gdje je primenjivo)',
            ),
            _spacer(24),
            _sectionTitle('8. Zaštita Podataka'),
            _spacer(8),
            _body(
              'Primenjujemo odgovarajuće tehničke i organizacione mere zaštite:\n'
              '- Enkripcija: Svi podaci u tranzitu zaštićeni su SSL/TLS enkripcijom\n'
              '- Pristup: Ograničen pristup podacima samo ovlašćenom osoblju\n'
              '- Monitoring: Redovni monitoring sistema radi detekcije bezbednosnih incidenata\n'
              '- Ažuriranja: Redovno ažuriranje i testiranje bezbednosnih mera',
            ),
            _spacer(24),
            _sectionTitle('9. Čuvanje Podataka'),
            _spacer(8),
            _body(
              'Vaše lične podatke čuvamo dok:\n'
              '- Vaš nalog je aktivan\n'
              '- Je potrebno za pružanje usluga\n'
              '- Je zakonski obavezno\n\n'
              'Rokovi čuvanja:\n'
              '- Podaci o nalogu: Dok je nalog aktivan + 30 dana nakon brisanja\n'
              '- Podaci o rezervacijama: 3 godine (iz računovodstvenih razloga)\n'
              '- Marketing saglasnosti: Do opoziva saglasnosti\n'
              '- Tehnički logovi: 90 dana\n\n'
              'Nakon isteka roka, podaci se bezbedno brišu ili anonimizuju.',
            ),
            _spacer(24),
            _sectionTitle('10. Vaša Prava'),
            _spacer(8),
            _body(
              'U skladu sa GDPR-om i srpskim Zakonom o zaštiti podataka o ličnosti, imate sledeća prava:\n'
              '- Pravo na pristup: Možete zatražiti kopiju vaših ličnih podataka\n'
              '- Pravo na ispravku: Možete zatražiti ispravku netačnih podataka\n'
              '- Pravo na brisanje: Možete zatražiti brisanje vaših podataka ("pravo na zaborav")\n'
              '- Pravo na ograničenje obrade: Možete zatražiti privremeno ograničenje obrade\n'
              '- Pravo na prenosivost: Možete dobiti vaše podatke u struktuiranom formatu\n'
              '- Pravo na prigovor: Možete prigovoriti obradi podataka za određene svrhe\n'
              '- Pravo na opoziv saglasnosti: Možete povući saglasnost u bilo kom trenutku\n\n'
              'Kako ostvariti vaša prava:\n'
              'Možete ostvariti svoja prava slanjem zahteva na [kontakt email] ili putem podešavanja u aplikaciji. Odgovorićemo na vaš zahtev u roku od 30 dana.',
            ),
            _spacer(24),
            _sectionTitle('11. Deca'),
            _spacer(8),
            _body(
              'Naša aplikacija nije namenjena deci mlađoj od 16 godina. Svesno ne prikupljamo lične podatke dece. Ako postanemo svesni da smo prikupili podatke deteta bez roditeljske saglasnosti, preduzećemo korake da uklonimo te podatke.',
            ),
            _spacer(24),
            _sectionTitle('12. Kolačići i Tehnologije Praćenja'),
            _spacer(8),
            _body(
              'Naša aplikacija koristi sledeće tehnologije:\n'
              '- Neophodni kolačići: Za osnovno funkcionisanje aplikacije (autentifikacija, sesije)\n'
              '- Analitički kolačići: Za razumevanje korišćenja aplikacije (uz vašu saglasnost)\n'
              '- Funkcionalni kolačići: Za pamćenje vaših podešavanja\n\n'
              'Možete upravljati kolačićima kroz podešavanja u aplikaciji ili browseru.',
            ),
            _spacer(24),
            _sectionTitle('13. Izmene Politike Privatnosti'),
            _spacer(8),
            _body(
              'Zadržavamo pravo da ažuriramo ovu Politiku privatnosti. O značajnim izmenama obaveštavamo vas putem:\n'
              '- Email obaveštenja\n'
              '- Push notifikacija u aplikaciji\n'
              '- Obaveštenja prilikom sledećeg prijavljivanja\n\n'
              'Nastavak korišćenja aplikacije nakon izmena predstavlja prihvatanje nove politike.',
            ),
            _spacer(24),
            _sectionTitle('14. Kontakt'),
            _spacer(8),
            _body(
              'Za pitanja o ovoj Politici privatnosti ili obradi vaših podataka:\n\n'
              'Rez Padel\n'
              'Email: [kontakt email]\n'
              'Adresa: [poslovna adresa]\n\n'
              'Padel Space (za pitanja o vašim podacima):\n'
              'Email: [email padel space-a]\n'
              'Adresa: [adresa padel space-a]\n\n'
              'Poverenik za informacije od javnog značaja i zaštitu podataka o ličnosti:\n'
              'Website: www.poverenik.rs\n'
              'Email: office@poverenik.rs\n\n'
              '---\n\n'
              'Korišćenjem Rez Padel aplikacije, potvrđujete da ste pročitali i razumeli ovu Politiku privatnosti.',
            ),
            _spacer(16),
          ],
        ),
      ),
    );
  }
}

