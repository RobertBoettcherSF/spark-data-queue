# spark-data-queue

[![SPARK](https://img.shields.io/badge/SPARK-Proved-brightgreen.svg)](https://www.spark-2014.org/)
[![Ada](https://img.shields.io/badge/Ada-2012-blue.svg)](https://www.adaic.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version: 0.01](https://img.shields.io/badge/Version-0.01-orange.svg)](VERSION)

---

## 📋 **Zusammenfassung / Summary**

**Deutsch:** Eine thread-sichere, formal verifizierte Warteschlange (FIFO) in SPARK/Ada für eingebettete Echtzeitsysteme.

**English:** A thread-safe, formally verified queue (FIFO) in SPARK/Ada for embedded real-time systems.

---

## 🎯 **Zweck / Purpose**

### Warum dieses Projekt? / Why this project?

- **Echtzeit-Systeme:** Wichtig für eingebettete Systeme wie cFS (Core Flight System) Portierungen
- **Formal Verifiziert:** SPARK-Beweise für Abwesenheit von Race Conditions
- **Thread-Sicher:** sichere Nebenläufigkeit für kritische Anwendungen
- **Lernprojekt:** Praktische Erfahrung mit SPARK und Nebenläufigkeit

### Anwendungsfälle / Use Cases

- Nachrichtenweiterleitung in Echtzeitsystemen
- Task-Kommunikation in eingebetteten Systemen
- Datenpufferung mit formalen Garantien
- cFS (Core Flight System) Anwendungen

---

## 🏗️ **Architektur / Architecture**

```
spark-data-queue/
├── VERSION                    # Aktuelle Version / Current version
├── README.md                 # Diese Datei / This file
├── LICENSE                   # MIT Lizenz / MIT License
├── .gitignore
├── src/
│   └── queue/
│       ├── spark_data_queue.ads    # Spezifikation / Specification
│       ├── spark_data_queue.adb    # Implementierung / Implementation
│       └── spark_data_queue.gpr    # Projektdatei / Project file
├── tests/
│   ├── test_queue.adb        # Testimplementierung
│   └── test_queue.gpr        # Testprojekt
└── examples/
    ├── simple_example.adb    # Einfaches Beispiel
    └── cfs_example.adb        # cFS-ähnliches Beispiel
```

---

## 📦 **Inhalt / Features**

### ✅ Implementierte Features

1. **Generischer Queue-Typ** - Typ-sichere Warteschlange für beliebige Datentypen
2. **Enqueue/Dequeue Operationen** - Standard FIFO-Operationen
3. **Thread-Sicherheit** - Schutz vor Race Conditions durch SPARK-Synchronisation
4. **Optionale Größebegrenzung** - Konfigurierbare maximale Queue-Größe
5. **Formal Verifiziert** - SPARK-Beweise für:
   - Abwesenheit von Race Conditions
   - Korrekte FIFO-Semantik
   - Speichersicherheit
   - Keine Pufferüberläufe

### 🔧 API Übersicht / API Overview

```ada
-- Queue erstellen / Create queue
function Create_Queue (Max_Size : Positive := Positive'Last) return Queue_Type;

-- Element hinzufügen / Enqueue element
procedure Enqueue (Q : in out Queue_Type; Item : Element_Type);

-- Element entfernen / Dequeue element
procedure Dequeue (Q : in out Queue_Type; Item : out Element_Type);

-- Queue leeren / Check if empty
function Is_Empty (Q : Queue_Type) return Boolean;

-- Queue voll / Check if full
function Is_Full (Q : Queue_Type) return Boolean;

-- Aktuelle Größe / Current size
function Size (Q : Queue_Type) return Natural;

-- Maximale Größe / Maximum size
function Max_Size (Q : Queue_Type) return Positive;
```

---

## 🔬 **Formal Verification / Formale Verifikation**

### SPARK-Beweise / SPARK Proofs

Die Implementierung enthält SPARK-Annotationen für:

1. **Race Condition Freiheit** - `Global` und `Depends` Kontrakte
2. **Speichersicherheit** - Keine Pufferüberläufe, keine Dangling Pointer
3. **FIFO-Korrektheit** - Elemente werden in der richtigen Reihenfolge verarbeitet
4. **Thread-Sicherheit** - Synchronisierter Zugriff auf gemeinsame Daten

### Verifizierte Eigenschaften / Verified Properties

```spark
-- Keine Race Conditions
procedure Enqueue (Q : in out Queue_Type; Item : Element_Type)
  with Global => (In_Out => Q),
       Depends => (Q => Q'Old, Item => null);

-- FIFO-Garantie
-- # assert for all i in 1..Q.Size'Old => 
-- #   (Dequeue_Sequence(i) = Enqueue_Sequence(i));
```

---

## 🚀 **Schnellstart / Quick Start**

### Voraussetzungen / Prerequisites

- [GNAT Community Edition](https://www.adacore.com/community) oder [Alire](https://alire.ada.dev/)
- SPARK 2014 Toolchain (inkl. GNATprove)
- Git

### Installation / Installation

```bash
# Repository klonen / Clone repository
git clone https://github.com/RobertBoettcherSF/spark-data-queue.git
cd spark-data-queue

# Projekt bauen / Build project
gprbuild -P src/queue/spark_data_queue.gpr

# Tests ausführen / Run tests
gprbuild -P tests/test_queue.gpr
```

### Einfaches Beispiel / Simple Example

```ada
with Spark_Data_Queue;

procedure Simple_Example is
   package Integer_Queue is new Spark_Data_Queue (Element_Type => Integer);
   use Integer_Queue;

   Q : Queue_Type := Create_Queue (Max_Size => 10);
   Item : Integer;
begin
   -- Elemente hinzufügen / Add elements
   Enqueue (Q, 42);
   Enqueue (Q, 100);
   Enqueue (Q, -5);

   -- Elemente entfernen / Remove elements
   while not Is_Empty (Q) loop
      Dequeue (Q, Item);
      Put_Line ("Dequeued:" & Item'Image);
   end loop;
end Simple_Example;
```

---

## 🧪 **Tests / Testing**

### Testabdeckung / Test Coverage

- ✅ Grundlegende Enqueue/Dequeue Operationen
- ✅ Queue Überlauf / Overflow Handling
- ✅ Queue Unterlauf / Underflow Handling
- ✅ Thread-Sicherheitstests
- ✅ Größebegrenzungstests
- ✅ FIFO-Korrektheitstests

### Tests ausführen / Running Tests

```bash
# Alle Tests bauen und ausführen
cd tests
gprbuild -P test_queue.gpr
./obj/test_queue

# Einzelne Tests
./obj/test_queue --test=basic_operations
./obj/test_queue --test=thread_safety
```

---

## 📊 **Performance / Leistung**

### Zeitkomplexität / Time Complexity

| Operation | Komplexität / Complexity |
|-----------|------------------------|
| Enqueue   | O(1)                   |
| Dequeue   | O(1)                   |
| Is_Empty  | O(1)                   |
| Is_Full   | O(1)                   |
| Size      | O(1)                   |

### Speicherbedarf / Memory Usage

- **Statisch:** Konfigurierbare maximale Größe
- **Dynamisch:** Keine dynamische Speicherallokation (für Echtzeitsysteme)

---

## 🔄 **Versionshistorie / Version History**

| Version | Datum / Date | Änderungen / Changes |
|---------|--------------|---------------------|
| 0.01    | 2024-01-XX   | Initiales Release: Grundlegende Queue-Implementierung mit SPARK-Verifikation |

---

## 📚 **Dokumentation / Documentation**

### SPARK-Ressourcen / SPARK Resources

- [SPARK 2014 Documentation](https://docs.adacore.com/spark2014-docs/html/lrm/index.html)
- [SPARK Tutorial](https://www.spark-2014.org/getting-started)
- [GNATprove User's Guide](https://docs.adacore.com/gnatprove-docs/html/)

### Ada-Ressourcen / Ada Resources

- [Ada Reference Manual](https://www.adaic.org/resources/add_content/standards/12rm/html/RM-TTL.html)
- [Ada for Embedded Systems](https://www.adacore.com/embedded)

---

## 🤝 **Mitwirken / Contributing**

### Beitragsrichtlinien / Contribution Guidelines

1. **Fork** das Repository
2. **Branch** erstellen (`git checkout -b feature/amazing-feature`)
3. **Commit** deine Änderungen (`git commit -m 'Add amazing feature'`)
4. **Push** zum Branch (`git push origin feature/amazing-feature`)
5. **Pull Request** öffnen

### Code-Standards / Coding Standards

- SPARK 2014 kompatibel
- Formale Verifikation wo möglich
- Klare Kontrakte und Annotationen
- Dokumentation in Englisch und Deutsch

---

## 📜 **Lizenz / License**

Dieses Projekt ist unter der MIT-Lizenz lizenziert - siehe [LICENSE](LICENSE) für Details.

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

---

## 📞 **Kontakt / Contact**

- **Autor:** Robert Boettcher
- **Repository:** [RobertBoettcherSF/spark-data-queue](https://github.com/RobertBoettcherSF/spark-data-queue)
- **Issues:** [GitHub Issues](https://github.com/RobertBoettcherSF/spark-data-queue/issues)

---

## 🏷️ **Tags / Keywords**

`spark` `ada` `queue` `fifo` `thread-safe` `formal-verification` `embedded` `real-time` `cFS` `concurrency` `race-condition` `safety-critical`

---

*Erstellt mit ❤️ für sichere eingebettete Systeme / Created with ❤️ for safe embedded systems*