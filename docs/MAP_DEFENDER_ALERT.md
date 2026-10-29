# Alerta confirmado pelo usuário — pacote do continente

Atualização: 28/10/2026. **Uso da entrega não recomendado enquanto o alerta estiver sem análise conclusiva.** Não houve confirmação de falso positivo, remoção de malware identificado ou liberação de antivírus. Não gere outro ZIP nem renomeie o arquivo para tentar eliminar o bloqueio.

## Registro recebido

- Microsoft Defender: **`Trojan:Script/Ulthar.A!ml`**.
- Item afetado: `webfile`, arquivo `Downloads/Eldravyn-Continent-Task01.zip`.
- Origem informada: `raw.githubusercontent.com/fernando-vaccari/RPG-Roblox/refs/heads/codex/eldravyn-map-20261027/delivery-map/task-01/Eldravyn-Continent-Task01.zip`.
- O registro não identifica um membro interno. Os bytes removidos na máquina do usuário não puderam ser comparados; a investigação usa o artefato versionado nesta branch, entregue em `fcbd9d1`.

| Artefato preservado para análise | SHA-256 |
| --- | --- |
| `Eldravyn-Continent-Task01.zip` | `a8405f31f653ab96655813af83268a2fc8e1f9b50e6ae6303e9e8733474b49c0` |
| Membro `Eldravyn-Continent.rbxlx` | `a08fd280bd8835943f3e29c0777196e277831cb39e1405560cc892779fc49dab` |

## O que a nova ocorrência muda

O ZIP do continente contém **somente um `.rbxlx`**. Não contém instaladores PowerShell/Python ou ferramentas nativas. Portanto retirar os instaladores não resolveu o problema e a hipótese desses auxiliares não explica esta nova ocorrência. A causa exata continua indeterminada; o nome da detecção e o caminho do contêiner não bastam para localizar a assinatura.

Não foram alterados código, compressão, nomes ou extensões para tentar escapar da detecção. Os artefatos e seus hashes permanecem preservados para rastreabilidade. Links de uso/download em destaque foram retirados do README desta entrega; arquivos ainda podem existir no Git/histórico, o que não constitui recomendação de uso.

## Verificações realmente executadas

- CRC e inventário: ZIP de 1.054.706 bytes com exatamente um membro; esse membro coincide byte a byte com o `.rbxlx` versionado e seu hash registrado.
- Parsing XML e comparação de **40 Sources** com os arquivos do projeto. Buscas estáticas direcionadas não encontraram loaders `loadstring`, require numérico/remoto, execução de código HTTP ou referências externas Content/ContentId/LinkedSource.
- Segunda revisão estática independente: **2.469 blobs**, todos `AttributesSerialize`, decodificados até o fim como metadados nativos, sem tipos desconhecidos ou dados restantes. Não foram localizados URLs/payloads de código nesses atributos.
- As URLs de fonte observadas são 151 referências nativas a `rbxasset://fonts/families/Guru.json`, não carregamentos HTTP. A revisão independente também verificou 300.679 valores numéricos XML finitos.
- Evidência estruturada: [alert-review.json](security/map-task-01/alert-review.json).
- Não há Microsoft Defender, ClamAV ou YARA instalados neste Linux. **Não executamos varredura de antivírus, sandbox Windows ou Roblox Studio.** Nenhum membro do ZIP foi executado nesta investigação.

Essas verificações de formato, código e integridade **não provam que o arquivo é inofensivo**, não explicam a assinatura da Microsoft e não invalidam o bloqueio. Nenhum código malicioso foi identificado no escopo da análise, mas falta o veredicto do fabricante. Não foram repetidos testes de gameplay: nenhum código de jogo foi alterado nesta etapa.

## Encaminhamento

Mantenha a proteção ativa, não crie exclusões e não restaure o arquivo da quarentena para executá-lo. Solicite análise pelo portal oficial da Microsoft: <https://www.microsoft.com/en-us/wdsi/filesubmission>. Informe o registro do Defender, nome completo da ameaça, URL de origem, versão/commit e os hashes acima; o fabricante deve analisar o artefato exato. Nenhuma submissão foi feita automaticamente nesta sessão.

Antes de retomar a entrega para uso, obter novas evidências do Defender/Microsoft e registrar o resultado. Após isso, a preparação de Terrain e os testes visuais no Studio continuam sendo etapas separadas ainda pendentes.
