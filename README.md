# Análise Preditiva de Salários: Regressão Ridge, Lasso e ElasticNet
> Trabalho realizado para a disciplina: Estatística Aplicada II, no curso de Inteligência Artifical Aplicada da UFPR

Este projeto consiste em uma análise estatística exploratória e aplicação de modelos de Machine Learning para prever o logaritmo do salário-hora de mulheres (`lwage`), comparando métodos de regularização para lidar com multicolinearidade e seleção de variáveis.

## 🎯 Objetivo

O foco principal é identificar quais variáveis socioeconômicas (educação, experiência, características do cônjuge, presença de filhos) possuem maior influência no salário e construir o modelo preditivo com o menor erro possível.

## 🛠 Metodologia

1. **Pré-processamento**: Padronização (center e scale) de variáveis contínuas e criação de variáveis *dummy* para fatores categóricos.

2. **Divisão de Dados**: O dataset foi particionado em 80% para treinamento e 20% para teste.

3. **Métricas de Avaliação**: Foram utilizados o **Erro Quadrático Médio da Raiz (RMSE)** e o **Coeficiente de Determinação (R^{2})** para medir a eficácia dos modelos.

---

## 🔍 Análise Preliminar (MQO)

Antes da regularização, foi realizada uma regressão linear múltipla (Mínimos Quadrados Ordinários) para entender a significância das variáveis.

* **Significância de 99,99%**: `husearns` (ganhos do marido), `earns` (ganhos totais), `union` (presença em sindicato) e `kidlt6` (filhos menores de 6 anos).

* **Significância de 95%**: `hushrs` (horas trabalhadas pelo marido).

* **Ajuste Inicial**: O modelo inicial apresentou um R^{2} Ajustado de **0,6894**.

---

## 🤖 Modelos Implementados

### 1. Modelo Ridge (\alpha = 0)

Foca na redução da magnitude dos coeficientes para evitar *overfitting*, mas mantém todas as variáveis no modelo.

* **Principais Variáveis**: `husearns` (Média +), `black` (Média -) e `kidlt6` (Média +).

### 2. Modelo Lasso (\alpha = 1)

Realiza a seleção de variáveis, zerando coeficientes de variáveis irrelevantes.

* **Variáveis Excluídas**: `husage`, `husunion`, `husblck`, `hispanic` e `exper`.

* **Alta Influência**: `educ` e `union`.

### 3. Modelo ElasticNet (0 < \alpha < 1)

Combina as penalidades de Ridge e Lasso para encontrar um equilíbrio.

* **Hiperparâmetros Otimizados**: \alpha = 0,378 e \lambda = 0,0127.

---

## 📊 Comparação de Performance

### Resultados no Conjunto de Teste

| Modelo | RMSE | R^{2} |
| --- | --- | --- |
| **Ridge** | 0.9893 | 0.2590 |
| **Lasso** | 0.9894 | 0.2588 |
| **ElasticNet** | **0.5007** | **0.2589** |

> **Nota**: O modelo **ElasticNet** apresentou o melhor desempenho geral devido ao menor RMSE, indicando predições mais próximas dos valores reais.

---

## 💰 Predições e Intervalos de Confiança

Simulação de predição para um perfil específico com Intervalo de Confiança (IC) de 95%:

| Modelo | Valor Predito (Salário/Hora) | Intervalo Inferior | Intervalo Superior |
| --- | --- | --- | --- |
| Ridge | $9.71 | $9.50 | $9.92 |
| Lasso | $8.65 | $8.46 | $8.84 |
| **Elastic** | **$8.02** | **$7.87** | **$8.16** |

---

## ✅ Conclusão

O modelo **ElasticNet** foi selecionado como o mais robusto para este problema. Observou-se que a exclusão da variável `earns` durante o treinamento dos modelos de regularização (embora presente no pré-teste de MQO) pode ter impactado a redução do R^{2} nos modelos finais, dado que ela possuía a maior influência no salário.

---
