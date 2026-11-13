# Threat model – Feel & Flow 🔐

## 1. Co chráníme
- Data o menstruaci (začátek, konec), plodné dny – zdravotní údaje, zvláštní kategorie dle GDPR
- Do budoucna: symptomy a poznámky a hlasové poznámky

## 2. Kde data jsou
- Pouze v zařízení, šifrovaně (flutter_secure_storage)
- Žádný server, žádný účet, žádné odesílání dat
- GitHub obsahuje jen kód, žádná data uživatelek

## 3. Kdo může být útočník
- Člověk s přístupem k odemčenému telefonu (partner, rodič, spolubydlící)
- Škodlivá aplikace v telefonu
- Útok přes knihovnu třetí strany (supply chain)

## 4. Hrozby a ochrana

| Hrozba | Příklad | Ochrana teď | Co chybí |
|---|---|---|---|
| Neoprávněné čtení dat | Někdo vezme odemčený telefon | Šifrované úložiště | Zámek aplikace (PIN/otisk) |
| Únik přes zálohu | Záloha telefonu do cloudu | – | Ověřit nastavení záloh na Androidu |
| Slabší ochrana na webu | Šifrovací klíč leží v prohlížeči | Web jen pro vývoj | Nepublikovat webovou verzi s reálnými daty |
| Podvržená knihovna | Škodlivá aktualizace balíčku | Ověřené balíčky, CI testy | Dependabot, připnutí verzí |
| Únik přes náhled aplikace | Obsah vidět v přepínači aplikací | – | Skrýt obsah v náhledu |

## 5. Známé chyby
- Dnešní den se v plodných dnech zobrazuje šedě místo modře (UX)

## 6. Další kroky
- [ ] Zámek aplikace
- [ ] Dependabot
- [ ] Ověřit zálohy na Androidu