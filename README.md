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

### blink_optim

Hierbei handelt es sich um eine minimale Umsetzung des busy waiting. Diese erreicht die Anforderungen mit 32 Byte im Flash.

### blink_watchdog_partial

Erreicht ein periodisches Blinken der LED mit nur 16 Byte im Flash. Die LED ist dabei zwar 1s aus, aber nur 50ms an.

### blink_watchdog_interrupt

Eine Umsetzung mit dem WDT, die die Anforderungen erfüllt, dabei aber 38 Byte benötigt aufgrund der Interrupt Vektor Tabelle

### blink_watchdog_interrupt_optim

Die Vorherige Version aber so weit minimiert, dass sie in 18 Byte Flash passt

### blink_watchdog_interrupt_optim_2

Durch einmaliges ausführliches Schreiben des Registers kann ein weitere Aufruf entfernt werden. Das Programm braucht nur noch 16 Byte Flashspeicher

## Zusammenfassung

924 Byte blink.ino.bin
36 Byte blink.bin
32 Byte blink_optim.bin
38 Byte blink_watchdog_interrupt.bin
18 Byte blink_watchdog_interrupt_optim.bin
16 Byte blink_watchdog_interrupt_optim_2.bin
