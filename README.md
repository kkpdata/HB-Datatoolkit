# 1. Inleiding
Hydraulische Belastingen produceren is een complex geheel. De kennisoverdracht tussen alle partijen (Rijkswaterstaat, Deltares en marktpartijen) en kennis uit het verleden is essentieel bij de vrijgave van nieuwe van hydraulische belastingen. Vanaf mei 2021 wordt gestart met de productie van Hydraulische Belastingen databases (HRD’s) voor BOI, het Beoordelings- en Ontwerpinstrumentarium van Waterkeringen. Kennisoverdracht is daarvoor essentieel. Hier beschrijven we de opbouw van een gedeelde Toolkit met scripts die relevant zijn voor de totstandkoming van hydraulische belastingen. Het beschikbaar stellen van de Toolkit is gericht op de verbetering van de Productie en het B&O (PBO) van data van de Hydraulische Belastingen (HB data).

De afgelopen maanden hebben Arcadis, Deltares en HKV scripts verzameld die zij in het verleden hebben ontwikkeld voor verbetering en automatisering van werkzaamheden voor de productie van HB data. Zij hebben geen tools ontwikkeld, noch tools aangepast voor deze toolkit. De tools zijn door deze partijen 'as-is' uit verschillende archieven gehaald. De verzameling tools is een eerste aanzet tot de bouw van een gedeelde Toolkit. Bij deze tekst hoort een excelbestand [Toolkit catalogus yyyymmdd](https://github.com/kkpdata/HB-Datatoolkit/blob/main/A00%20Documentatie/Toolkit%20catalogus%2020210520.xlsx) dat dient als de catalogus van de scripts/tools voor de productie en controle van de HB data. In de tekstkader hieronder geven we de reikwijdte van de service van de toolkit aan om de rechten en plichten af te bakenen die kunnen worden uitgeoefend en afgedwongen door partijen die gebruik maken van de tools uit de verzameling.

Wij vragen andere partijen ook de tools aan te leveren die zij gebruiken bij het produceren van HB data voor BOI (uiteraard onder dezelfde voorwaarden). Zodoende wordt dit de plek voor kennisoverdracht tussen partijen d.m.v. tools.

De verzameling van tools is te vinden op: https://github.com/kkpdata/HB-Datatoolkit

---
_**Rijkswaterstaat is eigenaar van de toolkit. Als eigenaar heeft zij de betrokken partijen gevraagd om tools aan te leveren zonder aanvullende services als beheer, onderhoud en helpdesk activiteiten. De tools zijn door de betrokken partijen vanuit hun archief ('as is') aangeleverd. Het is nooit de bedoeling geweest dat de tools zonder enige inspanning (studie) door een derde partij ingezet kunnen worden voor de productie van HB data. Het gebruik van de tools uit de verzameling gebeurt naar eigen goeddunken en op eigen risico en met de afspraak dat de derde partij als enige verantwoordelijk is voor enige schade aan uw computersysteem, verlies van gegevens of productie van verkeerde data als gevolg van het gebruik van de tools. De derde partij is als enige verantwoordelijk voor adequate bescherming en back-up van de gegevens en apparatuur die worden gebruikt en Rijkswaterstaat is niet aansprakelijk voor enige schade die u mogelijk lijdt in verband met het downloaden, installeren, gebruiken, wijzigen of het verspreiden van de tools. Geen enkel advies of informatie, mondeling of schriftelijk, die van Rijkswaterstaat of van de betrokken partijen is verkregen, vormt een garantie voor een juiste inzet van de tools.**_

---

# 2. Stappenplan PBO HB data
De productie, het beheer en het onderhoud (afgekort: PBO) van de HB data zijn omvangrijke, complexe, foutgevoelige en kostbare activiteiten. In [De Waal et. al (2020)](https://github.com/kkpdata/HB-Datatoolkit/blob/main/A00%20Documentatie/PBO%20HB%20data%20stappenplan%2013%20(11205758-014-GEO-0001_v1.0).pdf) is een modulaire opbouw van het proces PBO HB data vastgelegd in de vorm van een stappenplan. De samenhang tussen de stappen uit [De Waal et. al (2020)](https://github.com/kkpdata/HB-Datatoolkit/blob/main/A00%20Documentatie/PBO%20HB%20data%20stappenplan%2013%20(11205758-014-GEO-0001_v1.0).pdf) zijn in de figuur hieronder weergegeven. 

![image](A00&#32;Documentatie/Stappenplan.png)
*Figuur 1: Het stappenplan van de productieketen HB data, met genummerde procestappen (bron: [De Waal et. al (2020)](https://github.com/kkpdata/HB-Datatoolkit/blob/main/A00%20Documentatie/PBO%20HB%20data%20stappenplan%2013%20(11205758-014-GEO-0001_v1.0).pdf))*

Voor een uitgebreide toelichting op de stappen verwijzen we naar [De Waal et. al (2020)](https://github.com/kkpdata/HB-Datatoolkit/blob/main/A00%20Documentatie/PBO%20HB%20data%20stappenplan%2013%20(11205758-014-GEO-0001_v1.0).pdf). De ondersteuning van het gehele proces vindt plaats met tools op het niveau van deelprocessen c.q. processtappen. Tools die in het verleden voor één of meerdere deelprocessen zijn gebruikt, zijn verzameld in de toolkit. Het is gelukt om tools aan te dragen voor de stappen S02, S03, S05, S06, S07 en S11. Omdat in het verleden bovenstaande indeling niet voorgeschreven was (was destijds ook niet beschikbaar), komt het voor dat de verzamelde tools niet een 1-op-1 vertaling zijn van het gehele deelproces.

# 3. Beschrijving tools
Om de verzameling overzichtelijk te houden zijn de tools beschreven aan de hand van de volgende kenmerken:

Nr|Kenmerk|Toelichting
---|---|---
1|Scriptnaam|Titel van de tool in de catalogus.
2|Affiliatie|Dit betreft de organisatie waar de contactpersoon werkt (bijv. Arcadis / Deltares / HKV / ...).
3|Datum indienen|Dit helpt de gebruiker om vernieuwing of toevoegingen te kunnen monitoren.
4|Processtap productieketen|Hierbij wordt aangesloten op de namen en nummering uit het stappenplan ([De Waal et. al (2020)](https://github.com/kkpdata/HB-Datatoolkit/blob/main/A00%20Documentatie/PBO%20HB%20data%20stappenplan%2013%20(11205758-014-GEO-0001_v1.0).pdf)).
5|Taal|De programmeertaal of -omgeving van de tool, bijv. Excel, Python of Matlab.
6|Werking script op hoofdlijnen|Dit beslaat hooguit een paar regels, met de essentie van de tool.
7|Opmerkingen|Dit is een vrij veld.

# 4. Advies
Wij adviseren Rijkswaterstaat om het gebruik van de tools uit de verzameling te stimuleren bij haar opdrachtnemers. De toolkit biedt kansen om gezamenlijk met marktpartijen de beschikbare kennis over de productie van HB data te ontsluiten en te delen. Hierbij is het prettig als toekomstige gebruikers de mogelijkheid wordt geboden om een terugkoppeling van het gebruik te geven. Dit kan in eerste instantie in de vorm van een e-mail en/of memo met bevindingen als bijproduct van de werkzaamheden voor BOI.

Wij adviseren Rijkswaterstaat ook om partijen te vragen de tools aan te leveren die gebruikt worden bij het produceren van HB data voor BOI (onder dezelfde voorwaarden als eerder aangegeven in deze tekst). Dit GitHub-adres wordt daarmee het adres voor kennisoverdracht aangaande HB-data d.m.v. tools.

# 5. Referenties
- [H. de Waal, Stijnen J.W., Bosch, van der P. (2020). Productie Beheer en Onderhoud (PBO) HB data stappenplan.](https://github.com/kkpdata/HB-Datatoolkit/blob/main/A00%20Documentatie/PBO%20HB%20data%20stappenplan%2013%20(11205758-014-GEO-0001_v1.0).pdf)

</br>

Laatste oplevering | -
---|---
Van|Ton Botterhuis (HKV), Matthijs Benit (Arcadis) en Hans de Waal (Deltares)
Datum|20 mei 2021
Projectnummer|PR4440.10
Status|Concept
Onderwerp|HB-Data toolkit
