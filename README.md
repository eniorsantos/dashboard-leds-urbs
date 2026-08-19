# Dashboard Leds Urbs

Dashboard interativo (em português) que mostra a **programação de veiculação dos painéis de LED** "Leds Urbs" (16 telas em Recife/PE), gerado a partir de uma planilha Excel (`Leds Urbs*.xlsx`, abas `LEDS` e `Controle Norberto`).

Elaborado para funcionar **sem instalação**: HTML+CSS+JS puros, com o SheetJS para ler `.xlsx` no navegador e Python apenas para gerar/atualizar os dados. O uso básico funciona 100% offline; apenas a **conexão ao Google Sheets** (atualização ao vivo) e a **gravação da configuração** exigem o servidor local (`iniciar.bat`).

---

## Visão geral

- **16 telas de LED** em Recife/PE, cada uma com uma programação de campanhas publicitárias.
- Cada campanha pode estar **veiculando** (atual) ou **reservada** (futura).
- A fonte dos dados é a planilha Excel `Leds Urbs*.xlsx` (abas `LEDS` e `Controle Norberto`).
- O painel é atualizável de **4 formas** (ver [Atualização dos dados](#atualização-dos-dados)).
- A configuração (links de planilhas do Google) fica em **`dashboard/config.json`** — não é usada a `localStorage` do navegador.

---

## Estrutura do projeto

```
dashboard/
├── atualizar_dados.py          # Converte a planilha .xlsx -> dashboard/dados.js (Python)
├── atualizar.bat               # Atalho para rodar atualizar_dados.py no Windows
├── atualizar.sh                # Idem, para Linux/macOS
├── iniciar.bat                 # Inicia o servidor local (servidor.py) e abre o navegador
├── iniciar.sh                  # Idem, para Linux/macOS
├── servidor.py                 # Servidor local: serve os estáticos + salva dashboard/config.json (POST)
├── instalar.bat                # Instalador para Windows (atalhos na Área de Trabalho)
├── instalar_linux.sh           # Instalador para Linux (atalhos .desktop)
├── instalar_macos.sh           # Instalador para macOS (atalhos .command)
├── desinstalar.bat             # Desinstalador para Windows
├── desinstalar.sh              # Desinstalador para Linux/macOS
└── dashboard/                  # O dashboard em si
    ├── index.html              # Dashboard interativo (HTML + CSS + JS) — app inteiro num arquivo
    ├── dados.js                # Dados gerados (window.DADOS_LEDS) — NÃO editar à mão
    ├── config.json             # Configurações salvas (planilhas do Google) — gravado pelo servidor
    └── lib/
        └── xlsx.full.min.js    # SheetJS (lê .xlsx no navegador, usado no upload)
```

> `index.html` concentra todo o app (CSS, HTML e JS). O JS é extraído para testes por **`extract.py`** (fora do repositório, em `%TEMP%\opencode\`) — ver [Testes](#testes-desenvolvimento).

---

## Como usar

1. **Preferencialmente**, dê dois cliques em **`iniciar.bat`** — inicia o `servidor.py` em `http://localhost:8000/` e abre `http://localhost:8000/dashboard/` no navegador. É **obrigatório** para:
   - conectar ao **Google Sheets** (o Google bloqueia requisições vindas de `file://`);
   - **salvar a configuração** (`config.json`), pois só o `servidor.py` grava esse arquivo.
2. Ou simplesmente **abra** `dashboard\index.html` no navegador (sem instalação) — todo o painel funciona, exceto a conexão ao Google e a gravação de configuração.
3. Se os dados já foram gerados (`dados.js`), o painel é exibido imediatamente. Se existir uma planilha padrão salva no `config.json`, ele também já conecta nela automaticamente ao abrir.
4. Sem `dados.js`, o painel mostra apenas a área de "Carregar planilha".

> **Parar o servidor**: feche a janela do `iniciar.bat` (ou pressione Ctrl+C).

### Recursos do painel

- **KPIs**: total de telas, campanhas ativas agora, fixas, apoio, reservadas, futuras e encerradas.
- **Atenção**: listas "encerram em 7 dias" e "iniciam em 21 dias".
- **Situação**: gráfico de barras com campanhas por situação.
- **Anunciantes**: ranking dos que mais veiculam telas.
- **Linha do tempo (Gantt)**: uma pista por tela de LED, com barras coloridas por situação, marcação **HOJE**, linha de meses e *tooltip* com campanha/tela/período.
- **Filtros**: busca por campanha, por tela, por seção (veiculando/reservadas) e por situação (Ativa agora, Fixa, Apoio, Futura, Encerrada).
- **Tabela**: detalhamento **agrupado por tela** (cabeçalho por LED com número + nome), com menu de atalho acima da tabela que rola até cada tela (#N + contagem de campanhas). Colunas: tela, campanha, seção, início, fim, tipo, situação.
- **Imprimir / PDF**: botão no cabeçalho (CSS de impressão incluso).
- **Upload do arquivo**: arraste um `.xlsx` ou clique em "Carregar planilha" para atualizar na hora.
- **✏️ Editar no Google**: aparece ao conectar uma planilha — abre o editor do Google (janela nova). No link publicado, abre a visualização.
- **Google Sheets**: conecta o painel a uma planilha online com **atualização em tempo real** (ver abaixo).
- **⚙️ Configurações**: menu lateral no cabeçalho — gerencia **várias planilhas do Google Sheets** (adicionar, definir padrão, carregar, excluir); no cabeçalho, **📊 Escolher planilha…** troca de planilha num clique.

### Menu ⚙️ Configurações (lateral)

Abre um painel lateral (gaveta) com a lista de **planilhas do Google** salvas:

- **Nome (opcional)** + **Link/ID do Google Sheets** + botão **＋ Adicionar planilha** (duplicados não entram).
- Cada item da lista tem:
  - **Carregar** — conecta na hora e move a planilha para o topo;
  - **★ Padrão** — define a planilha que o painel carrega **automaticamente ao abrir**;
  - **🗑️ Excluir** — remove (com confirmação); se a excluída era a padrão, a próxima assume como padrão.
- No cabeçalho, o menu **📊 Escolher planilha…** troca entre as salvas num clique (desabilitado quando não há nenhuma).

A lista é guardada no arquivo **`dashboard/config.json`** (não em `localStorage`), gravado pelo `servidor.py` via `POST`. Formato:

```json
{
  "planilhas": [
    { "nome": "Matriz", "url": "https://docs.google.com/spreadsheets/d/…/edit" },
    { "nome": "",       "url": "…/d/e/…/pub?output=xlsx" }
  ]
}
```

A primeira entrada da lista é a **padrão** (usada ao abrir o painel).

### Servidor local (`servidor.py`)

Servidor HTTP em Python (Windows, sem dependências extras) usado pelo `iniciar.bat`:

| Rota | Método | Descrição |
| --- | --- | --- |
| `/…/*` | GET | Servir os arquivos (igual ao `python -m http.server`), da raiz do projeto |
| `/dashboard/config.json` | POST | Salva a configuração no arquivo `dashboard/config.json` (valida JSON; 400 se inválido) |

Uso manual: `python servidor.py` (porta 8000) ou `python servidor.py 8080` (porta qualquer).

> Abrir o `index.html` direto (`file://`) **não** consegue salvar a configuração — nesse caso o painel funciona em memória e mostra um aviso ao tentar salvar.

---

## Instaladores

Os instaladores copiam o projeto para uma pasta permanente e criam atalhos no Desktop. Todos seguem o mesmo fluxo: definir o destino → copiar os arquivos → verificar Python/openpyxl → criar os atalhos. O Python é **opcional** em todos os casos (necessário apenas para regenerar `dados.js`); a instalação nunca exige privilégios de administrador.

### Windows — `instalar.bat`

- **Duplo clique**: instala em `%USERPROFILE%\Dashboard Leds Urbs`.
- **Linha de comando**: `instalar.bat "C:\Outra\Pasta"`.
- Cria atalhos **"Dashboard Leds Urbs"** e **"Atualizar dados (Leds Urbs)"** na Área de Trabalho (usa `OneDrive\Desktop` se `Desktop` não existir).
- Para desinstalar, execute o `desinstalar.bat` que fica na pasta instalada.

### Linux — `instalar_linux.sh`

```sh
./instalar_linux.sh                          # instala em $HOME/Dashboard Leds Urbs
./instalar_linux.sh "/outra/pasta"           # caminho alternativo
```

- Detecta `python3`/`python` e instala `openpyxl` via `pip` se faltar (se o `pip` não existir — ex.: Ubuntu sem `python3-pip` — o instalador avisa como instalar).
- Cria atalhos `.desktop` no Desktop (detecta `$HOME/Desktop` ou `xdg-user-dir DESKTOP`) e os marca como confiáveis (`gio set metadata::trusted`).
- Para desinstalar, execute o `desinstalar.sh` que fica na pasta instalada.

### macOS — `instalar_macos.sh`

```sh
./instalar_macos.sh                          # instala em $HOME/Dashboard Leds Urbs
./instalar_macos.sh "/outra/pasta"           # caminho alternativo
```

- Cria atalhos `.command` no Desktop (clique duplo abre o painel ou atualiza os dados no Terminal).
- Python: instale com `xcode-select --install` (Ferramentas de Desenvolvedor) ou baixe de <https://www.python.org>; o instalador detecta `python3`/`python` e o `openpyxl` como no Linux (se o `pip` não existir, ele avisa, ex.: `/usr/bin/python3 -m ensurepip --upgrade`).
- Para desinstalar, execute o `desinstalar.sh` que fica na pasta instalada.

### Scripts auxiliares (comuns a Linux/macOS)

| Script | Equivale a (Windows) | O que faz |
| --- | --- | --- |
| `iniciar.sh` | `iniciar.bat` | Sobe o `servidor.py` e abre `http://localhost:8000/dashboard/` (via `open` no macOS ou `xdg-open` no Linux) |
| `atualizar.sh` | `atualizar.bat` | Roda `atualizar_dados.py` (procura a planilha mais recente em Downloads/Documents) |
| `desinstalar.sh` | `desinstalar.bat` | Remove os atalhos do SO correspondente e apaga a pasta instalada (confirma com `SIM`) |

> Os scripts `.sh` são POSIX (`#!/bin/sh`) e detectam o SO via `uname`. Depois de instalar, o uso é idêntico ao de [Como usar](#como-usar), trocando `iniciar.bat` por `iniciar.sh` — os atalhos criados já fazem isso automaticamente.

---

## Atualização dos dados

O que quer que você mude na planilha, o dashboard usa **sempre a planilha como fonte da verdade**.

### Opção A — duplo clique (mais simples)

1. Salve a planilha editada em **Downloads** ou **Documents** (o script acha a mais recente `Leds Urbs*.xlsx`).
2. Dê dois cliques em `atualizar.bat` (Windows) ou `atualizar.sh` (Linux/macOS) — ou use o atalho "Atualizar dados (Leds Urbs)" criado pelo instalador.
3. Reabra `dashboard\index.html`.

### Opção B — linha de comando

```bat
python atualizar_dados.py                          REM procura a planilha mais recente automaticamente
python atualizar_dados.py "C:\caminho\Leds Urbs.xlsx"   REM ou informe o arquivo
```

### Opção C — dentro do navegador (sem Python)

No painel, clique em **📄 Carregar planilha (.xlsx)** e selecione o arquivo (ou arraste sobre a área de upload). O arquivo é lido localmente via SheetJS e o painel é renderizado na hora — nada é enviado à internet.

> **Observação**: a Opção C não grava o arquivo em disco. Para fixar os novos dados (compartilhar/abrir em outra máquina sem a planilha), rode a Opção A/B para regenerar o `dados.js`.

### Opção D — Google Sheets (atualização em tempo real)

No painel, clique em **🌐 Google Sheets**. O campo aceita **3 formatos**:

1. **Link de planilha publicada** (`https://docs.google.com/spreadsheets/d/e/…/pub?output=xlsx`) — o mais prático: no Google, use *Arquivo → Compartilhar → Publicar na web* e cole o link. O painel baixa o `.xlsx` publicado e o atualiza em tempo real (nenhuma configuração).
2. **Link normal** (`…/spreadsheets/d/{ID}/…`) — exige compartilhar como **"Qualquer pessoa com o link"** e usa a conexão pública (gviz); **API Key opcional** permite planilha privada (Sheets API v4).
3. **Apenas o ID** da planilha.

Informe a **frequência**: manual, 15 s, 30 s ou 60 s, e clique em **Conectar**.

> **Várias planilhas**: no menu **⚙️ Configurações** você salva quantos links quiser (com nome opcional). Cada item tem botões **Carregar** (conecta agora), **★ Padrão** (a que o painel carrega automaticamente ao abrir) e **🗑️ Excluir** (remove). No cabeçalho, o menu **📊 Escolher planilha…** permite trocar de planilha num clique. A lista fica no arquivo **`dashboard/config.json`** (não usa `localStorage`), na própria pasta do painel — o `servidor.py` grava nesse arquivo quando você salva pelas Configurações.

O painel passa a reconsultar o Google automaticamente (polling a cada N segundos) e re-renderiza KPIs, timeline, tabela e menus com os dados mais recentes — exibe o status "🟢 Ao vivo · atualizado às HH:MM:SS". Botões: **Atualizar agora** (força uma busca) e **Desconectar** (volta aos dados embutidos/uploadados).

> **Importante**: o Google **bloqueia** a conexão quando o painel é aberto direto do arquivo (`file://` — erro "Failed to fetch"). Abra sempre pelo `iniciar.bat` (`http://localhost:8000/dashboard/`). O caminho pela **API Key** (Sheets API v4) funciona mesmo de `file://`.

> Na planilha publicada, a aba pode ter outro nome (ex.: "Página1") — o painel detecta automaticamente a aba que segue o formato "Leds Urbs" (labels `inicio`/`Fim` na linha 3). No link normal com a Sheets API v4, é exigida uma API Key gratuita no Google Cloud ([guia](https://developers.google.com/workspace/sheets/api/guides/authorize)) — com planilha pública (link compartilhado) a conexão gviz não exige nada.


---

## Como funciona a conversão

### Aba `LEDS` (16 blocos de telas)

Cada tela ocupa um bloco de colunas. A detecção é dinâmica:

| O quê | Onde está |
| --- | --- |
| Nome da tela | **Linha 1** (coluna onde há texto) |
| "Campanhas veiculando" | Linha 2 (referência visual) |
| Labels `inicio` / `Fim` / `programação` | **Linha 3** — usados para achar as colunas de cada bloco |
| Campanhas **veiculando** | Linhas **4 a 12** |
| Campanhas **reservadas** | Linhas **14 a 22** |

- Se a linha 3 não tiver os labels, usa-se o padrão `nome+1`, `nome+2`, `nome+3`.
- Valor **`----`** (ou `-`, ou vazio) = slot vazio → ignorado.
- `FIXO` e `Apoio` na coluna de início são guardados no campo `ini_texto` (tipo de campanha), não como data.

### Aba `Controle Norberto`

- Linhas com data na coluna A e campanha na coluna B (região na C e nº de regiões na D, opcionais).
- Linhas sem campanha são puladas.

### Formato de saída (`dashboard/dados.js`)

```js
window.DADOS_LEDS = {
  "fonte":      "Leds Urbs_v2.xlsx",
  "gerado_em":  "2026-08-18 10:00",
  "locais": [
    {
      "numero": 1,
      "nome": "Nome da Tela",
      "campanhas": [
        {
          "nome": "Nome da Campanha",
          "inicio": "2026-08-01",      // ISO (ou null se não houver data)
          "fim":    "2026-08-31",
          "prog":   "texto livre",
          "ini_texto": null,            // "FIXO", "Apoio" ou null
          "secao": "veiculando" | "reservadas",
          "indice": null
        }
      ]
    }
  ],
  "controle": [
    { "data": "2023-07-03", "campanhas": "Assai", "regiao": null, "n_regioes": null }
  ]
};
```

### Situação calculada de cada campanha (`estadoCamp`)

| Situação | Condição |
| --- | --- |
| **Fixa** | `ini_texto` = `FIXO` |
| **Apoio** | `ini_texto` = `Apoio` |
| **Ativa agora** | com datas e `inicio <= hoje <= fim` |
| **Futura** | com datas e `inicio > hoje` |
| **Encerrada** | com datas e `fim < hoje` |
| **Sem data** | sem data de início/fim |

---

## Detalhes técnicos importantes

- **Datas com SheetJS**: lidas com `cellDates: true` vêm como `Date` em UTC (meia-noite). No fuso do Brasil (UTC−3) os getters locais apontam para o dia anterior, então **todas** as conversões usam getters UTC (`getUTCFullYear/getUTCMonth/getUTCDate` em `iso()`). O mesmo vale para o Python (`v.date().isoformat()`).
- **Precedência na concatenação de strings** (timeline): expressões como `'" y2="'+fim-ini` quebram a string; sempre use parênteses, ex.: `'" y2="'+(fim-ini)`.
- **Segurança**: todo texto exibido passa por `esc()` (escape de `<>&"'`), inclusive *tooltips* da timeline (injeção XSS evitada).
- **Escape de datas**: o parser aceita datas ISO, `YYYY/MM/DD` e `DD/MM/YYYY` (função `parseDataTexto`).
- A aba `Controle Norberto` ainda é parseada no JS/Python, mas o botão "Histórico · Controle" foi removido do painel; o campo `controle` em `dados.js` permanece disponível no objeto de dados.

---

## Estrutura do código (`index.html`)

Todo o app é um único arquivo (`<style>` + HTML + `<script>`). Principais blocos/funções:

| Área | Funções |
| --- | --- |
| **Helpers** | `pad`, `hojeISO`, `iso` (getters UTC), `diasEntre`, `fmtBr`, `esc` (escape XSS), `toast`, `parseDataTexto` |
| **Classificação** | `tipoCamp` (FIXA/APOIO/PERIODO), `estadoCamp` (FIXA/APOIO/ATIVA/FUTURA/ENCERRADA/SEM_DATA) |
| **Parse da planilha** | `parseXLSX(wb)` — mesma regra do Python (blocos na linha 3, veiculando 4–12, reservadas 14–22, `FIXO`/`Apoio` → `ini_texto`) |
| **Render** | `renderAll()` → `renderKPIs`, `renderAtencao`, `renderSituacao`, `renderTop`; e `renderViews()` → `renderTimeline` (Gantt SVG), `renderTable`, `renderGrupos`, `irTela` |
| **Upload** | `initDrop`, `carregarArquivo` (FileReader + SheetJS) → `parseXLSX` → render |
| **Google Sheets** | `gsProcessarUrl`, `gsFetchGviz`, `gsFetchApi`, `gsToWB`, `gsWbGviz`, `gsCarregar`, `gsConectar`, `gsDesconectar`, `editarGoogle`, `gsStatus` (polling 15s/30s/60s) |
| **Configuração** | `cfgCarregarConfig` (fetch `config.json`), `cfgLer/cfgPersistir` (POST), `cfgRender`, `cfgAdicionar/cfgRemover/cfgPadrao/cfgCarregar`, `selPlanilha`, `openConfig/fecharConfig` |
| **Inicialização** | `init()` (DOMContentLoaded): prepara upload, monta selects KPI/menus, e `cfgCarregarConfig(cfgAplicar)` — carrega as planilhas salvas e conecta na padrão |

**Fluxo dos dados**: planilha → (`atualizar_dados.py` gera `dados.js`) ou (upload/SheetJS) ou (Google Sheets via gviz/API/publica) → `parseXLSX` → `DADOS` → `renderAll`/`renderViews`. O Google (quando conectado) faz polling e re-renderiza automaticamente.

**Configuração**: ao salvar (adicionar/excluir/padrão), o JS atualiza a memória e envia `POST /dashboard/config.json` ao `servidor.py`; ao abrir, faz `fetch('config.json')`. Se não houver servidor gravável (ex.: `file://`), funciona em memória e avisa. Uma migração única lê as antigas chaves do `localStorage` e as move para o arquivo.

---

## Dependências

| Ferramenta | Onde é usada | Versão testada |
| --- | --- | --- |
| Python + `openpyxl` | `atualizar_dados.py` (geração de `dados.js`) | Python 3.11.2, openpyxl 3.1.5 |
| Node.js | apenas para testes de desenvolvimento | v22.23.1 |
| SheetJS (`xlsx.full.min.js`) | leitura do `.xlsx` no navegador (upload) | 0.20.3 |

Instalação do Python: `pip install openpyxl`

---

## Testes (desenvolvimento)

Os testes validam que o parse no navegador (JS) produz **exatamente** os mesmos dados do Python (16 locais, 120 campanhas, 300 registros de controle — valores da planilha atual) e que o render não gera `NaN`, quebra de string ou conteúdo inseguro.

Como rodar (na pasta de trabalho `%TEMP%\opencode\`):

1. `extract.py` extrai o `<script>` do `index.html` para `dbg.js` (modo Node: injeta `module.exports`).
2. Cada teste roda com `node`, usando um *wrapper* que fornece mocks mínimos de `window`, `document`, `XLSX` (a lib real) e `localStorage`:
   - `test_parse.js` — parse do `dados.js` e distribuição de tipos (`FIXO` 10, `APOIO` 15, vazio 95).
   - `test_final.js` — saída "sadia" do render (sem `NaN`/`undefined`/`[object Object]`).
   - `test_grupo.js` — agrupamento por tela (16 grupos, contagens corretas).
   - `test_telas.js` — menu de telas e IDs dos grupos.
   - `test_atencao.js` — listas de atenção (encerram em 7 dias / iniciam em 21).
   - `test_cfg.js` / `test_multi.js` / `test_del.js` — testes pontuais de desenvolvimento (fluxos do menu de configuração, múltiplas planilhas e exclusão).

Estados esperados (hoje de referência nos testes = `2026-08-18`): ATIVA 32, FIXA 10, APOIO 15, FUTURA 37, ENCERRADA 16 (timeline), reservadas 41.

> Este pacote de testes fica na pasta temporária (`%TEMP%\opencode\`) e **não faz parte do repositório** — serve para desenvolvimento/verificação rápida.

---

## Arquivos de origem (fora do repositório)

- `C:\Users\enio\Downloads\Leds Urbs_v2.xlsx` — planilha-fonte atual.
- `C:\Users\enio\Documents\Leds Urbs.xlsx` — versão alternativa.
- `C:\Users\enio\Downloads\Leds Urbs_v2.pdf` — anexo em PDF (não usado; o modelo de dados vem do `.xlsx`).
