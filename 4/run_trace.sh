#!/bin/bash

TRACE=$1

TRACE_FILENAME=$(basename "$TRACE")
OUTPUT="results_${TRACE_FILENAME}.txt"

echo "Начинаем симуляцию для трассы: $TRACE"

echo "=== ОТЧЕТ ДЛЯ ТРАССЫ $TRACE_FILENAME ===" > "$OUTPUT"

for BIN in bin_experiments/champsim_*
do
  echo "Сейчас работает: $BIN"

  echo "БИНАРНИК: $BIN" >> "$OUTPUT"

  $BIN --warmup-instructions 50000000 --simulation-instructions 100000000 $TRACE | grep "cpu0_L2C TOTAL" >> "$OUTPUT"

  echo "----------------------------------------" >> "$OUTPUT"
done

echo "Готово! Данные в файле: $OUTPUT"
