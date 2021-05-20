**Verwijzingen naar documentatie met links**

**Disclaimer omhoog?**

# Inleiding
**De huidige opzet ploft er een beetje lopm in. Eerst iets van "dit is een gedeelde toolkit**

Hydraulische Belastingen produceren is een complex geheel. De kennisoverdracht tussen alle partijen (Rijkswaterstaat, Deltares en marktpartijen) en kennis uit het verleden is essentieel bij de vrijgave van nieuwe van hydraulische belastingen. Vanaf mei 2021 wordt gestart met de productie van Hydraulische Belastingen databases (HRD’s) voor BOI, het Beoordelings- en Ontwerpinstrumentarium van Waterkeringen. Kennisoverdracht is daarvoor essentieel.

 **Op deze pagina / In dit memo** beschrijven we de opbouw van deze gedeelde Toolkit met scripts die relevant zijn voor de totstandkoming van hydraulische belastingen. Het beschikbaar stellen van de Toolkit is gericht op de verbetering van de Productie en het B&O (PBO) van data van de Hydraulische Belastingen (HB data). Het beschikbaar stellen van de scripts is een vorm van kennisoverdracht omdat nieuwe opdrachtnemers daardoor de werkwijze van voorbije projecten in meer detail tot zich kunnen nemen dan het geval zou zijn bij het nalezen van rapportage.

De afgelopen maanden hebben Arcadis, Deltares en HKV scripts verzameld die zij in het verleden hebben ontwikkeld voor verbetering en automatisering van werkzaamheden voor de productie van HB data. De verzameling tools is een eerste aanzet tot de bouw van een gedeelde Toolkit. Bij dit memo hoort een excelbestand 'Script catalogus v05 22042022.xlsx'  dat dient als een catalogus van scripts/tools voor de productie en controle. In de tekstbox hieronder geven we de reikwijdte van de service van de catalogus aan, om de rechten en plichten af te bakenen die kunnen worden uitgeoefend en afgedwongen door partijen die gebruik maken van de tools uit de catalogus.

---
_**Rijkswaterstaat is eigenaar van de catalogus. Als eigenaar heeft zij de betrokken partijen gevraagd om tools aan te leveren zonder aanvullende services als beheer, onderhoud en helpdesk activiteiten. De tools zijn door de betrokken partijen vanuit hun archief ('as is') aangeleverd. Het is nooit de bedoeling geweest dat de tools zonder enige inspanning (studie) door een derde partij ingezet kunnen worden voor de productie van HB data. Het gebruik van de tools uit de catalogus gebeurt naar eigen goeddunken en op eigen risico en met de afspraak dat de derde partij als enige verantwoordelijk is voor enige schade aan uw computersysteem, verlies van gegevens of productie van verkeerde data als gevolg van het gebruik van de tools. De derde partij is als enige verantwoordelijk voor adequate bescherming en back-up van de gegevens en apparatuur die worden gebruikt en Rijkswaterstaat is niet aansprakelijk voor enige schade die u mogelijk lijdt in verband met het downloaden, installeren, gebruiken, wijzigen of het verspreiden van de tools. Geen enkel advies of informatie, mondeling of schriftelijk, die van Rijkswaterstaat of van de betrokken partijen is verkregen, vormt een garantie voor een juiste inzet van de tools.**_

---

# Stappenplan PBO HB data
De productie, het beheer en het onderhoud (afgekort: PBO) van de HB data zijn omvangrijke, complexe, foutgevoelige en kostbare activiteiten. In De Waal et. al (2020) is een modulaire opbouw van het proces PBO HB data vastgelegd in de vorm van een stappenplan. De samenhang tussen de stappen uit De Waal et. al (2020) zijn in de figuur hieronder weergegeven.

![image](Stappenplan.png)
*Figuur 1: Het stappenplan van de productieketen HB data, met genummerde procestappen (bron: De Waal et. al, 2020)*

Voor een uitgebreide toelichting op de stappen verwijzen we naar De Waal et. al (2020). De ondersteuning van het gehele proces vindt plaats met tools op het niveau van deelprocessen c.q. processtappen. Tools die in het verleden voor één of meerdere deelprocessen zijn gebruikt, zijn verzameld in de catalogus. Omdat in het verleden bovenstaande indeling niet voorgeschreven was (was destijds ook niet beschikbaar), komt het voor dat de verzamelde tools niet een 1-op-1 vertaling zijn van het gehele deelproces. 

# Beschrijving tools
Om de verzameling overzichtelijk te houden zijn de tools beschreven aan de hand van de volgende kenmerken:

Nr|Kenmerk|Toelichting
---|---|---
1|Scriptnaam|Titel van de tool in de catalogus.
_**2**_|_**Ontwikkelaar**_|_**Contactpersoon, degene die het script heeft gebouwd.**_
3|Affiliatie|Dit betreft de organisatie waar de contactpersoon werkt (bijv. Arcadis / Deltares / HKV / ...).
4|Datum indienen|Dit helpt de gebruiker om vernieuwing of toevoegingen te kunnen monitoren.
5|Processtap productieketen|Hierbij wordt aangesloten op de namen en nummering uit het stappenplan (De Waal et. al, 2020).
6|Taal|De programmeertaal of -omgeving van de tool, bijv. Excel, Python of Matlab.
7|Werking script op hoofdlijnen|Dit beslaat hooguit een paar regels, met de essentie van de tool
8|Opmerkingen|Dit is een vrij veld.

# Advies
@@@

# Referenties
- H. de Waal, Stijnen J.W., Bosch, van der P. (2020). Productie Beheer en Onderhoud (PBO) HB data stappenplan.