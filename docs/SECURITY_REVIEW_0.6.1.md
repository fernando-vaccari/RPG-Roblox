# Investigação do alerta Defender — Eldravyn 0.6.1

## Resultado e limites

**A causa exata da detecção não foi identificada. Não classificamos o alerta como falso positivo nem declaramos o pacote seguro.** A revisão estática/estrutural não encontrou um payload malicioso nos itens inspecionados. Esse resultado não invalida o alerta do Defender e não é equivalente a uma análise de antivírus ou execução isolada em Windows.

Não há Microsoft Defender, ClamAV, YARA, PowerShell ou Roblox Studio disponíveis neste ambiente Linux. Não executamos varredura de antivírus, detonação de malware, PowerShell no Windows nem teste do jogo no Studio. Nenhuma configuração de segurança foi alterada e nenhum arquivo foi submetido automaticamente à Microsoft ou a outros serviços de análise.

## Evidência recebida e identificação da versão

- Nome completo informado pelo usuário: **`Trojan:Script/Ulthar.A!ml`**.
- O registro `webfile` aponta para `Downloads/RPG-Roblox-Windows11.zip`, vindo da URL raw do GitHub da branch `codex/rpg-quality-delivery-20261024`, em `delivery/RPG-Roblox-Windows11.zip`.
- O registro fornecido **não identifica um membro interno do ZIP**. Sem esse detalhe ou análise do fabricante, não é possível atribuir a detecção a um script específico.
- ZIP investigado: **437.883 bytes, 106 arquivos**; SHA-256 **`6e6f990a241d75821cfc9d2e36f601d3ae6749af68aea6139c502480a3194d65`**.
- Os bytes do ZIP local coincidem com o objeto Git do commit **`ad159de046f98198a191a0b33d8dc1fa80c1e472`**. Os 106 membros também coincidiam com o checkout no início da auditoria. Isso estabelece a versão investigada; não autentica os bytes que o Defender removeu da máquina do usuário, cujo hash não está disponível.

O ZIP anterior foi preservado, sem alteração de bytes. Os novos arquivos ficam em [delivery-minimal/0.6.1](../delivery-minimal/0.6.1), separados da entrega anterior.

## Revisão dos arquivos

| Conteúdo do ZIP anterior | Quantidade | Verificação e observações |
| --- | ---: | --- |
| Luau | 65 | Inspeção estática dos padrões de execução/carregamento, rede e módulos. São 50 arquivos de produção, 10 de testes e 5 scripts de apoio. Não encontramos `loadstring`, execução de payload codificado, `require` de asset numérico/remoto, webhook ou carregamento de código HTTP. Os `require` de produção referenciam módulos locais. A busca por padrões é limitada e não prova ausência de malware. |
| Python | 8 | Leitura dos scripts completos e parsing AST sem executar membros do ZIP. Imports são da biblioteca padrão. Subprocessos de build usam executáveis locais/comandos explícitos, sem shell com entrada do jogador. Instalador grava ferramentas em `.tools/bin`; geração de áudio, catálogo, build e ZIP escreve em pastas do projeto. |
| PowerShell | 2 | Leitura completa de `install-tools.ps1` e `check.ps1`. O instalador baixa ZIPs oficiais, confere hashes fixos, extrai/copia ferramentas e remove sua própria pasta temporária criada com GUID. O check executa ferramentas locais. Não encontramos alterações do Defender, exclusões, comandos codificados, registro/serviços/tarefas agendadas, elevação ou persistência no Windows. Nenhum dos dois foi executado nesta investigação. |
| JSON de projeto/manifesto | 3 | Parsing JSON e revisão dos dois mapeamentos Rojo. Não há hooks de shell ou referências a dependências remotas nos projetos. Os serviços/módulos do jogo são locais. |
| Places XML `.rbxlx` | 2 | Parsing XML: cada Place possui 48 ModuleScripts, um Script e um LocalScript. **Todos os 50 Sources de cada Place coincidem com os fontes do ZIP**. Não encontramos Scripts adicionais, PackageLink, LinkedSource, blobs BinaryString/SharedString, Content/ContentId externos ou entidades/DOCTYPE. XML contém scripts Roblox; não é um arquivo sem código. |
| Áudio WAV | 3 | RIFF/WAVE com comprimento declarado igual ao arquivo, PCM mono, 16 bits, 22.050 Hz; parsing com a biblioteca `wave`. Isso verifica formato, não é varredura antimalware. |
| Markdown/TXT/`.gitignore` | 23 | Conferidos bytes/hashes, formato UTF-8 sem NUL e proveniência no arquivo versionado. Incluem documentação e pedidos anteriores do usuário; não são executados pelo build. |

O inventário de **cada um dos 106 membros, seus tamanhos e SHA-256** está em [archive-audit.json](security/0.6.1/archive-audit.json). CRC, nomes únicos inclusive por comparação sem distinguir maiúsculas, caminhos relativos, ausência de links simbólicos/criptografia, formatos esperados e fim do ZIP sem dados anexados passaram. Não há `.exe`, `.dll`, `.bat`, `.cmd`, `.vbs`, `.js`, `.lnk` ou arquivos ZIP aninhados no pacote investigado. As ferramentas nativas citadas nos instaladores **não estavam dentro do ZIP**.

### Comportamentos relevantes e possíveis causas ainda não confirmadas

1. **Instalador PowerShell:** contém `Invoke-WebRequest`, extração de arquivo, cópia de executáveis e `Remove-Item -Recurse -Force` restrito à pasta temporária recém-criada. São operações reais de um instalador; o script não contém assinatura Authenticode. Esse conjunto merece revisão em um alerta `Trojan:Script`, mas não temos evidência de que tenha disparado essa assinatura. O caminho `webfile` sozinho não demonstra isso.
2. **Downloads de ferramentas:** Python/PowerShell obtêm Rojo 7.7.1 de `rojo-rbx/rojo` e Luau 0.744 de `luau-lang/luau` por HTTPS e exigem SHA-256 fixo. Nesta investigação baixamos novamente os dois arquivos Windows e o Rojo Linux, **sem executar os binários Windows**, e os três hashes coincidiram. O Rojo Linux instalado também coincidiu byte a byte com o binário do release conferido. Isso confirma correspondência com essas origens, não ausência de vulnerabilidades/malware upstream.
3. **Insumo externo de teste:** `scripts/integration.py` baixa `API-Dump.json` de `MaximumADHD/Roblox-Client-Tracker` se não houver cache. Essa dependência é JSON de terceiros, em branch móvel e sem hash fixo. É usada para montar o host de testes; não é baixada pelo jogo ou incluída na entrega mínima. Constitui uma dependência de cadeia de fornecimento a considerar, sem indício observado de comprometimento nesta revisão.
4. **Script de smoke Rojo:** consulta somente `127.0.0.1:34872`. Não envia o projeto a um serviço externo. As chamadas de HttpService no jogo são JSON/GUID; não encontramos chamadas HTTP externas do runtime. DataStore, compras e teleporte são APIs oficiais Roblox, com Place/produtos ainda em 0 na configuração entregue. Essa revisão não é uma auditoria completa de exploits do jogo.
5. **Demais conteúdos/heurística do contêiner:** scripts e XML continuam sendo possibilidades, pois não temos o membro apontado nem o veredicto do fabricante. Não há base para atribuir a causa exclusivamente aos instaladores ou prometer que reduzir o ZIP elimina o alerta.

Evidência dos downloads/hashes: [upstream-check.json](security/0.6.1/upstream-check.json). A busca estática direcionada de execução dinâmica, require remoto, alterações do antivírus e carregamento HTTP retornou zero ocorrências nos padrões definidos em `scripts/audit_delivery.py`. Padrões podem deixar escapar técnicas desconhecidas/indiretas; não são um mecanismo de detecção antimalware.

## Entrega mínima

**O novo ZIP contém exatamente dois membros, na raiz:**

```text
ProjectMedievalRPG.rbxlx
ProjectMedievalRPG_Dungeon.rbxlx
```

Não inclui instaladores, Python, PowerShell, executáveis, testes, WAV, documentos ou outros arquivos auxiliares. Relatório e hashes ficam **fora do ZIP**, no GitHub. Os dois `.rbxlx` também estão disponíveis individualmente, mantendo os nomes/extensões originais.

Os Places foram reconstruídos com o Rojo conferido e verificados estruturalmente. **São byte a byte idênticos aos Places dentro do ZIP que recebeu o alerta**. Nenhum código, identificação persistente ou funcionalidade foi removido/alterado para mudar uma detecção. A alteração é somente na composição da entrega; não se trata de remoção de um trojan identificado. A detecção pode persistir nos Places ou no pacote mínimo.

| Arquivo | Bytes | SHA-256 |
| --- | ---: | --- |
| `ProjectMedievalRPG.rbxlx` | 316.263 | `ada1163d26bbc45b42096cd7827627c194fe598a7343c902c4ed0b0f90dabde1` |
| `ProjectMedievalRPG_Dungeon.rbxlx` | 316.265 | `2c247bb1ade9ca4207d94472e519c4bd3694498baf28c664ad401eab2ad254f4` |
| `Eldravyn-0.6.1-Places.zip` | 171.646 | `0d66f526d774d960f6b886312432676977b1c91ec337c50d6a9727a7869550c4` |

Hashes comprovam identidade/integridade, **não inocuidade**. Também estão em [SHA256SUMS.txt](../delivery-minimal/0.6.1/SHA256SUMS.txt). Comparação dos Places novos/anteriores: [minimal-verification.json](security/0.6.1/minimal-verification.json).

## Comandos realmente executados

- `python3 scripts/audit_delivery.py`: inventário dos 106 membros, parsing, proveniência Git, comparação de Sources e busca estática. Não executa membros do ZIP nem os extrai para rodar.
- Downloads HTTPS dos releases oficiais e comparação SHA-256 com os três pins citados, conforme evidência JSON.
- `.tools/bin/rojo build default.project.json --output build/ProjectMedievalRPG.rbxlx` e equivalente para `dungeon.project.json`.
- `python3 scripts/verify_project.py`: dependências/serviços/estrutura dos dois builds; 48 módulos e dois bootstraps por Place.
- `python3 scripts/package_minimal.py`: allowlist de dois nomes, comparação com manifesto, CRC, bytes e SHA-256. Nenhum auxiliar entra nesse ZIP.
- Parsing AST dos dois novos scripts Python e `git diff --check`.
- Comparação adicional com o ZIP anterior: Places idênticos, ZIP anterior preservado.

Os testes de gameplay CLI/mock da correção 0.6.1 são histórico do commit anterior e **não foram repetidos nesta auditoria**; o código do jogo não mudou. Build/CRC/hash não substituem antivírus, análise de comportamento, assinatura digital ou testes no Studio. Verificações de download GitHub são registradas na mensagem de entrega após o envio.

## Se houver novo bloqueio

Mantenha o Defender ativo. Não restaure da quarentena para executar, não adicione exclusões e não desative a proteção. Se o Defender bloquear a nova entrega, interrompa seu uso e **submeta o arquivo à Microsoft para análise** pelo portal oficial: <https://www.microsoft.com/en-us/wdsi/filesubmission>.

Inclua o nome completo `Trojan:Script/Ulthar.A!ml`, URL/versão/commit, hash, registro do Histórico de proteção e versões do mecanismo/definições do Defender. Informe se o bloqueio ocorreu no ZIP antigo, no ZIP mínimo ou em um dos `.rbxlx`. Solicite um veredicto do fabricante; só esse retorno e novas evidências podem esclarecer a classificação. Não foi feita uma submissão nesta sessão.
