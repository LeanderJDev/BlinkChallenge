# Blink mit Watchdog

## Ziel

Das Blink‑Beispiel für einen AVR (z.B. ATmega328P) soll mit dem Watchdog Timer (WDT) als Reset‑Quelle auf eine möglichst kleine Größe im Flash gebracht werden.

## Anforderungen

1. LED 1s an
2. LED 1s aus
3. Wiederholen

Es dürfen Fuse Bits gesetzt werden
Es darf eine andere LED als die Builtin LED verwendet werden (aber weiterhin eine ohne eigene Logik)

## Voraussetzungen

- `avr-gcc`, `avr-objcopy` installiert (Toolchain)
- Programmer/Bootloader zum Flashen (z.B. `avrdude`) wenn du auf Hardware testest

## Build

1. Wähle die Assemblerdatei, z.B. `blink_watchdog.s`.
2. Baue das Firmware‑Hex mit dem mitgelieferten Script:

```
./build.sh blink_watchdog.s
```

Das erzeugt `blink_watchdog.hex` und `blink_watchdog.bin` im selben Verzeichnis.

## Flashen

Zum Flashen nutze dein übliches Flash‑Script oder `avrdude`. Beispiel (falls
`flash.sh` vorhanden ist):

```
./flash.sh blink_watchdog.hex
```

## Fuse Bits

Falls Fuse Bits gesetzt werden müssen gibt es dafür auch ein Shell Skript, allerdings habe ich dafür dann doch keine sinnvolle Verwendung gefunden, da die Watchdog Einstellungen über das entsprechende Register geschehen müssen.

## Erfolge

### 01_blink_optim

Hierbei handelt es sich um eine minimale Umsetzung des busy waiting. Diese erreicht die Anforderungen mit 32 Byte im Flash.

### 02_blink_watchdog_cheat

Erreicht ein periodisches Blinken der LED mit nur 16 Byte im Flash. Die LED ist dabei zwar 1s aus, aber nur 50ms an.

### 03_blink_watchdog_interrupt

Eine Umsetzung mit dem WDT, die die Anforderungen erfüllt, dabei aber 38 Byte benötigt aufgrund der Interrupt Vektor Tabelle

### 04_blink_watchdog_interrupt_optim

Die Vorherige Version aber so weit minimiert, dass sie in 18 Byte Flash passt

### 05_blink_watchdog_interrupt_optim_2

Durch einmaliges ausführliches Schreiben des Registers kann ein weitere Aufruf entfernt werden. Das Programm braucht nur noch 16 Byte Flashspeicher

## Zusammenfassung

| Implementation                          | Size     |
| --------------------------------------- | -------- |
| blink.ino.bin                           | 924 Byte |
| 00_blink.bin                            | 36 Byte  |
| 01_blink_optim.bin                      | 32 Byte  |
| 02_blink_watchdog_cheat                 | 16 Byte  |
| 03_blink_watchdog_interrupt.bin         | 38 Byte  |
| 04_blink_watchdog_interrupt_optim.bin   | 18 Byte  |
| 05_blink_watchdog_interrupt_optim_2.bin | 16 Byte  |

## Anleitung zum selbst Ausprobieren

1. Zum Vergleich kann erstmal das Arduino IDE Blink Example geflasht werden

```shell
# Kompilieren mit arduino-cli
arduino-cli compile --fqbn arduino:avr:uno --build-path build blink
# Flashen direkt aus dem build dir (könnte auch mit arduino-cli erfolgen)
./flash.sh build/blink.ino.hex /dev/<portname>
```

2. Im Vergleich dazu ist das Flashen des klassischen Blink Assembler-Codes in 00_blink interessant

```shell
# Kompilieren mit make
make build 00_blink
# Flashen mit make
make flash 00_blink PORT=/dev/<portname>
```

Alternativ ist das auch mit den Shellskripten möglich

```shell
# Kompilieren mit make
./build.sh 00_blink.s
# Flashen mit make
./flash.sh 00_blink.hex /dev/<portname>
```

3. Der gleiche Prozess kann mit den anderen Versionen durchgeführt werden. avrdude gibt dabei immer die Anzahl der geschriebenen Bytes aus
