import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          'Uslovi korišćenja',
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
            _title('Uslovi Korišćenja'),
            _spacer(8),
            _body('Poslednje ažuriranje: 6. decembar 2025.'),
            _spacer(24),
            _sectionTitle('1. Uvod i Prihvatanje Uslova'),
            _spacer(8),
            _body(
              'Dobrodošli u Rez Padel aplikaciju. Ovi Uslovi korišćenja ("Uslovi") predstavljaju pravno obavezujući ugovor između vas ("Korisnik", "Vi") i Rez Padel-a ("mi", "naš", "Aplikacija") koji reguliše vaše korišćenje Rez Padel mobilne aplikacije i povezanih usluga.\n\n'
              'Korišćenjem ove aplikacije, prihvatate da ste pročitali, razumeli i saglasni sa ovim Uslovima. Ako se ne slažete sa ovim Uslovima, nemojte koristiti aplikaciju.',
            ),
            _spacer(24),
            _sectionTitle('2. Definicije'),
            _spacer(8),
            _body(
              '- Rez Padel - softversko rešenje za upravljanje rezervacijama padel terena\n'
              '- Padel centar - fizički objekat (npr. Padel Space) koji koristi Rez Padel softver za upravljanje rezervacijama\n'
              '- Korisnik - svaka fizička osoba koja koristi aplikaciju za rezervaciju terena\n'
              '- Rezervacija - potvrđena najava termina za korišćenje padel terena\n'
              '- Nalog - korisnički profil kreiran prilikom registracije',
            ),
            _spacer(24),
            _sectionTitle('3. Opis Usluge'),
            _spacer(8),
            _body(
              'Rez Padel je softverska platforma koja omogućava:\n'
              '- Pregled dostupnosti terena u padel centrima\n'
              '- Online rezervaciju termina\n'
              '- Upravljanje rezervacijama (pregled, izmena, otkazivanje)\n'
              '- Online plaćanje rezervacija\n'
              '- Primanje obaveštenja o rezervacijama\n'
              '- Pregled istorije korišćenja usluga\n\n'
              'Važno: Rez Padel je isključivo tehnološki posrednik. Padel centri (kao što je Padel Space) su nezavisni pružaoci usluga i odgovorni su za kvalitet usluga igranja, održavanje terena i fizičke operacije objekta.',
            ),
            _spacer(24),
            _sectionTitle('4. Registracija i Nalog'),
            _spacer(8),
            _sectionTitle('4.1 Kreiranje Naloga'),
            _spacer(4),
            _body(
              '- Ime i prezime\n'
              '- Email adresa\n'
              '- Broj telefona\n'
              '- Lozinka (minimalno 8 karaktera)',
            ),
            _spacer(12),
            _sectionTitle('4.2 Odgovornost za Nalog'),
            _spacer(4),
            _body(
              'Vi ste odgovorni za:\n'
              '- Čuvanje poverljivosti vaših pristupnih podataka\n'
              '- Sve aktivnosti koje se obave putem vašeg naloga\n'
              '- Trenutno obaveštavanje nas o neovlašćenoj upotrebi naloga',
            ),
            _spacer(12),
            _sectionTitle('4.3 Tačnost Podataka'),
            _spacer(4),
            _body(
              'Garantujete da su svi podaci koje dostavljate tačni, potpuni i ažurni. Obavezujete se da redovno ažurirate svoje informacije.',
            ),
            _spacer(12),
            _sectionTitle('4.4 Uzrast'),
            _spacer(4),
            _body(
              'Morate imati najmanje 16 godina da biste koristili aplikaciju. Korisnici između 16 i 18 godina mogu koristiti aplikaciju samo uz saglasnost roditelja ili staratelja.',
            ),
            _spacer(24),
            _sectionTitle('5. Korišćenje Usluge'),
            _spacer(8),
            _sectionTitle('5.1 Dozvoljena Upotreba'),
            _spacer(4),
            _body(
              'Obavezujete se da ćete aplikaciju koristiti isključivo za:\n'
              '- Legitimne rezervacije termina\n'
              '- Upravljanje svojim rezervacijama\n'
              '- Komunikaciju sa padel centrima',
            ),
            _spacer(12),
            _sectionTitle('5.2 Zabranjena Upotreba'),
            _spacer(4),
            _body(
              'Zabranjeno je:\n'
              '- Koristiti tuđe podatke bez dozvole\n'
              '- Kreirati lažne ili višestruke naloge\n'
              '- Vršiti automatizovane rezervacije (botovi, skripte)\n'
              '- Zloupotrebljavati sistem rezervacija (npr. blokiranje termina bez namere korišćenja)\n'
              '- Ometati rad aplikacije ili servera\n'
              '- Pokušavati neovlašćeni pristup sistemu\n'
              '- Koristiti aplikaciju za bilo koju nezakonitu aktivnost\n'
              '- Prenositi viruse ili štetan kod\n'
              '- Kopirati, modifikovati ili distribuirati delove aplikacije\n'
              '- Vršiti reverse engineering aplikacije',
            ),
            _spacer(24),
            _sectionTitle('6. Rezervacije i Plaćanja'),
            _spacer(8),
            _sectionTitle('6.1 Proces Rezervacije'),
            _spacer(4),
            _body(
              '- Rezervacije se vrše kroz aplikaciju za dostupne termine\n'
              '- Svaka rezervacija mora biti potvrđena i plaćena\n'
              '- Potvrda rezervacije šalje se putem email-a i push notifikacije',
            ),
            _spacer(12),
            _sectionTitle('6.2 Cene'),
            _spacer(4),
            _body(
              '- Cene terena određuje padel centar\n'
              '- Sve cene su prikazane u dinarima (RSD)\n'
              '- Cene mogu biti izmenjene od strane padel centra uz prethodno obaveštenje\n'
              '- Rez Padel ne naplaćuje dodatne naknade (osim eventualne naknade za obradu plaćanja)',
            ),
            _spacer(12),
            _sectionTitle('6.3 Plaćanje'),
            _spacer(4),
            _body(
              '- Plaćanje se vrši online putem bezbednih payment gateway-a\n'
              '- Prihvaćeni načini plaćanja: platne kartice (Visa, Mastercard, Dina)\n'
              '- Sva plaćanja su konačna nakon potvrde rezervacije\n'
              '- Ne čuvamo podatke o platnim karticama',
            ),
            _spacer(12),
            _sectionTitle('6.4 Otkazivanje i Povraćaj Sredstava'),
            _spacer(4),
            _body(
              'Politiku otkazivanja određuje svaki padel centar pojedinačno. Tipično:\n'
              '- Otkazivanje više od 24h pre termina: pun povraćaj\n'
              '- Otkazivanje 12-24h pre termina: 50% povraćaj\n'
              '- Otkazivanje manje od 12h pre termina: bez povraćaja\n'
              '- Nepojavljivanje (no-show): bez povraćaja\n\n'
              'Povraćaj sredstava:\n'
              '- Odobren povraćaj procesira se u roku od 5-10 radnih dana\n'
              '- Povraćaj se vrši na isti način plaćanja\n'
              '- Rez Padel zadržava pravo na administrativnu naknadu u slučaju zloupotrebe',
            ),
            _spacer(12),
            _sectionTitle('6.5 Izmena Rezervacija'),
            _spacer(4),
            _body(
              '- Izmena rezervacije moguća je u skladu sa dostupnošću terena\n'
              '- Neke izmene mogu biti besplatne, druge podležu naknadama\n'
              '- Politiku izmena određuje padel centar',
            ),
            _spacer(24),
            _sectionTitle('7. Odgovornost i Ograničenja'),
            _spacer(8),
            _sectionTitle('7.1 Uloga Rez Padel-a'),
            _spacer(4),
            _body(
              'Rez Padel je isključivo tehnološka platforma. Mi:\n'
              '- NE posedujemo padel terene\n'
              '- NE pružamo usluge igranja\n'
              '- NE kontrolišemo kvalitet usluga padel centara\n'
              '- NE garantujemo dostupnost terena',
            ),
            _spacer(12),
            _sectionTitle('7.2 Odgovornost Padel Centara'),
            _spacer(4),
            _body(
              'Padel centri (npr. Padel Space) su odgovorni za:\n'
              '- Održavanje i stanje terena\n'
              '- Kvalitet usluga igranja\n'
              '- Bezbednost korisnika u objektu\n'
              '- Dodatne usluge i opremu\n'
              '- Odobravanje i obradu povraćaja sredstava',
            ),
            _spacer(12),
            _sectionTitle('7.3 Ograničenje Odgovornosti'),
            _spacer(4),
            _body(
              'Rez Padel NIJE odgovoran za:\n'
              '- Povrede ili štetu nastalu tokom igranja\n'
              '- Kvalitet ili stanje terena\n'
              '- Ponašanje drugih korisnika ili osoblja padel centra\n'
              '- Kašnjenja ili otkazivanja termin od strane padel centra\n'
              '- Gubitak ili oštećenje lične imovine\n'
              '- Indirektnu, slučajnu ili posledičnu štetu\n'
              '- Nemogućnost korišćenja aplikacije ili gubitak podataka\n\n'
              'Maksimalna odgovornost: U slučaju bilo kakvih zahteva, naša maksimalna odgovornost ograničena je na iznos koji ste platili za rezervaciju u poslednjih 30 dana.',
            ),
            _spacer(12),
            _sectionTitle('7.4 Dostupnost Usluge'),
            _spacer(4),
            _body(
              'Trudimo se da aplikacija bude dostupna 24/7, ali:\n'
              '- Ne garantujemo neprekidan rad\n'
              '- Možemo privremeno suspendovati uslugu radi održavanja\n'
              '- Nismo odgovorni za prekide izazvane tehničkim problemima\n'
              '- Zadržavamo pravo da izmenimo ili obustavimo uslugu bilo kada',
            ),
            _spacer(24),
            _sectionTitle('8. Intelektualna Svojina'),
            _spacer(8),
            _sectionTitle('8.1 Naša Prava'),
            _spacer(4),
            _body(
              'Sva prava intelektualne svojine nad aplikacijom, uključujući:\n'
              '- Dizajn, logo i grafički elementi\n'
              '- Softverski kod i arhitektura\n'
              '- Tekstualni sadržaj\n'
              '- Baze podataka\n\n'
              'su vlasništvo Rez Padel-a ili naših licencera i zaštićeni su zakonima o autorskim pravima.',
            ),
            _spacer(12),
            _sectionTitle('8.2 Licenca za Korišćenje'),
            _spacer(4),
            _body(
              'Dajemo vam ograničenu, neizsključivu, neotuđivu licencu za:\n'
              '- Preuzimanje i instalaciju aplikacije na vašem uređaju\n'
              '- Korišćenje aplikacije za lične, nekomercijalne svrhe',
            ),
            _spacer(12),
            _sectionTitle('8.3 Zabrane'),
            _spacer(4),
            _body(
              'Zabranjeno je:\n'
              '- Kopirati, distribuirati ili modifikovati aplikaciju\n'
              '- Uklanjati autorska obaveštenja\n'
              '- Koristiti aplikaciju u komercijalne svrhe bez dozvole\n'
              '- Kreirati derivativne radove',
            ),
            _spacer(24),
            _sectionTitle('9. Sadržaj Korisnika'),
            _spacer(8),
            _sectionTitle('9.1 Vaš Sadržaj'),
            _spacer(4),
            _body(
              'Korisnici mogu dodavati sadržaj kao što su:\n'
              '- Profilne fotografije\n'
              '- Recenzije i ocene\n'
              '- Komentari',
            ),
            _spacer(12),
            _sectionTitle('9.2 Licenca Nam'),
            _spacer(4),
            _body(
              'Dodavanjem sadržaja, dajete Rez Padel-u svetsku, besplatnu, neograničenu licencu da koristi, reprodukuje, prikazuje i distribuira taj sadržaj u svrhe pružanja usluge.',
            ),
            _spacer(12),
            _sectionTitle('9.3 Odgovornost za Sadržaj'),
            _spacer(4),
            _body(
              'Vi ste isključivo odgovorni za sadržaj koji dodajete i garantujete da:\n'
              '- Imate prava na taj sadržaj\n'
              '- Sadržaj ne krši prava trećih strana\n'
              '- Sadržaj nije nezakonit, uvredljiv ili neprikladan',
            ),
            _spacer(12),
            _sectionTitle('9.4 Moderacija'),
            _spacer(4),
            _body(
              'Zadržavamo pravo da:\n'
              '- Uklonimo sadržaj koji krši ove Uslove\n'
              '- Suspendujemo naloge korisnika koji krše pravila\n'
              '- Ne moderiramo sadržaj proaktivno',
            ),
            _spacer(24),
            _sectionTitle('10. Privatnost i Zaštita Podataka'),
            _spacer(8),
            _body(
              'Prikupljanje i korišćenje vaših ličnih podataka regulisano je našom Politikom privatnosti. Korišćenjem aplikacije, prihvatate obradu podataka kako je opisano u Politici privatnosti.',
            ),
            _spacer(24),
            _sectionTitle('11. Obaveštenja i Komunikacija'),
            _spacer(8),
            _sectionTitle('11.1 Elektronska Komunikacija'),
            _spacer(4),
            _body(
              'Saglasni ste da primite komunikaciju od nas:\n'
              '- Putem email-a\n'
              '- Push notifikacija\n'
              '- SMS poruka (samo transakcione)\n'
              '- In-app obaveštenja',
            ),
            _spacer(12),
            _sectionTitle('11.2 Marketing Komunikacija'),
            _spacer(4),
            _body(
              'Marketing poruke šaljemo samo uz vašu eksplicitnu saglasnost. Možete odjavi u bilo kom trenutku kroz:\n'
              '- Link za odjavu u email-u\n'
              '- Podešavanja u aplikaciji',
            ),
            _spacer(12),
            _sectionTitle('11.3 Naša Obaveštenja'),
            _spacer(4),
            _body(
              'Važna obaveštenja (izmene uslova, bezbednosna pitanja) šaljemo svim korisnicima i ne mogu se odjavi.',
            ),
            _spacer(24),
            _sectionTitle('12. Raskid i Suspenzija'),
            _spacer(8),
            _sectionTitle('12.1 Vaše Pravo na Raskid'),
            _spacer(4),
            _body(
              'Možete zatvoriti nalog u bilo kom trenutku kroz:\n'
              '- Podešavanja u aplikaciji, ili\n'
              '- Kontaktiranjem naše podrške\n\n'
              'Nakon zatvaranja naloga:\n'
              '- Izgubićete pristup rezervacijama\n'
              '- Podaci će biti obrisani u skladu sa Politikom privatnosti\n'
              '- Aktivne rezervacije ostaju važeće',
            ),
            _spacer(12),
            _sectionTitle('12.2 Naše Pravo na Suspenziju/Raskid'),
            _spacer(4),
            _body(
              'Možemo suspendovati ili trajno zatvoriti vaš nalog ako:\n'
              '- Kršite ove Uslove\n'
              '- Zloupotrebljavate sistem\n'
              '- Vršite nezakonite aktivnosti\n'
              '- Ne plaćate rezervacije\n'
              '- Postoje bezbednosni rizici\n\n'
              'U slučaju raskida:\n'
              '- Možemo zadržati podatke za pravne svrhe\n'
              '- Nemate pravo na povraćaj plaćenih iznosa\n'
              '- Zabranjeno vam je kreiranje novog naloga',
            ),
            _spacer(24),
            _sectionTitle('13. Izmene Uslova'),
            _spacer(8),
            _sectionTitle('13.1 Pravo na Izmene'),
            _spacer(4),
            _body(
              'Zadržavamo pravo da izmenimo ove Uslove u bilo kom trenutku. O značajnim izmenama obaveštavamo vas:\n'
              '- Email obaveštenjem\n'
              '- Push notifikacijom\n'
              '- Obaveštenjem u aplikaciji',
            ),
            _spacer(12),
            _sectionTitle('13.2 Stupanje na Snagu'),
            _spacer(4),
            _body(
              'Izmene stupaju na snagu:\n'
              '- Nakon 30 dana od obaveštenja, ili\n'
              '- Odmah nakon vašeg prihvatanja',
            ),
            _spacer(12),
            _sectionTitle('13.3 Nastavak Korišćenja'),
            _spacer(4),
            _body(
              'Nastavkom korišćenja aplikacije nakon izmena, prihvatate nove Uslove. Ako se ne slažete, zatvorite nalog pre stupanja izmena na snagu.',
            ),
            _spacer(24),
            _sectionTitle('14. Opšte Odredbe'),
            _spacer(8),
            _sectionTitle('14.1 Primenjivo Pravo'),
            _spacer(4),
            _body(
              'Ovi Uslovi se tumače i primenjuju u skladu sa zakonima Republike Srbije.',
            ),
            _spacer(12),
            _sectionTitle('14.2 Nadležnost'),
            _spacer(4),
            _body(
              'Za sve sporove nadležan je sud u [grad sedišta Rez Padel-a].',
            ),
            _spacer(12),
            _sectionTitle('14.3 Rešavanje Sporova'),
            _spacer(4),
            _body(
              'U slučaju spora:\n'
              '1. Prvo pokušajte da kontaktirate našu podršku\n'
              '2. Potražite mirno rešenje\n'
              '3. Ako je neophodno, primeniti sudsko rešavanje',
            ),
            _spacer(12),
            _sectionTitle('14.4 Celokupnost Ugovora'),
            _spacer(4),
            _body(
              'Ovi Uslovi, zajedno sa Politikom privatnosti, predstavljaju celokupan ugovor između vas i Rez Padel-a.',
            ),
            _spacer(12),
            _sectionTitle('14.5 Odeljivost'),
            _spacer(4),
            _body(
              'Ako bilo koja odredba ovih Uslova bude proglašena nevažećom, ostale odredbe ostaju na snazi.',
            ),
            _spacer(12),
            _sectionTitle('14.6 Odricanje'),
            _spacer(4),
            _body(
              'Naše neinsistiranje na bilo kojoj odredbi ne predstavlja odricanje od tog prava.',
            ),
            _spacer(12),
            _sectionTitle('14.7 Prenos'),
            _spacer(4),
            _body(
              'Ne možete preneti svoja prava i obaveze iz ovih Uslova. Mi možemo preneti naša prava trećim stranama uz obaveštenje.',
            ),
            _spacer(12),
            _sectionTitle('14.8 Force Majeure'),
            _spacer(4),
            _body(
              'Nismo odgovorni za neispunjavanje obaveza usled okolnosti van naše kontrole (prirodne katastrofe, ratovi, pandemije, hakerski napadi, prekidi interneta).',
            ),
            _spacer(24),
            _sectionTitle('15. Kontakt'),
            _spacer(8),
            _body(
              'Za pitanja o ovim Uslovima korišćenja:\n\n'
              'Rez Padel\n'
              'Email: [kontakt email]\n'
              'Telefon: [broj telefona]\n'
              'Adresa: [poslovna adresa]\n\n'
              'Podrška:\n'
              'Email: podrska@rezpadel.com\n'
              'Radno vreme: Ponedeljak - Petak, 09:00 - 17:00h\n\n'
              '---\n\n'
              'Poslednja izmena: 6. decembar 2025.\n\n'
              'Preuzimanjem, instaliranjem ili korišćenjem Rez Padel aplikacije, potvrđujete da ste pročitali, razumeli i prihvatili ove Uslove korišćenja u celosti.',
            ),
            _spacer(16),
          ],
        ),
      ),
    );
  }
}

