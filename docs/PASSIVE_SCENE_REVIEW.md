# Cópia passiva: conteúdo e limites da revisão

Atualização: 28/10/2026. Solicitação: tentar entregar uma versão sem o alerta de antivírus. **Não é possível garantir esse resultado sem uma nova análise do Microsoft Defender/Microsoft.** Foi gerado um artefato exclusivamente de dados de cenário, com retirada real de toda a lógica de projeto; não foi feita alteração de payload, codificação ou embalagem para tentar mascarar a detecção.

## Transformação legítima do conteúdo

Origem preservada: `delivery-map/task-01/Eldravyn-Continent.rbxlx`, SHA-256 `a08fd280bd8835943f3e29c0777196e277831cb39e1405560cc892779fc49dab`.

Destino: `delivery-map/passive-scene/Eldravyn-Continent-SceneryOnly.rbxlx`, **25.690.068 bytes**, SHA-256 **`3162d264fee1d46dbdc6fe0aaaafef17934e0dda648c8c992ce6c01db037317e`**.

- Retidos apenas Workspace e Lighting, incluindo a hierarquia original de cenário, 20.001 BaseParts, 987 Models, placas, 16 luzes e cinco efeitos ambientais.
- Excluídos ReplicatedStorage, ServerScriptService, ServerStorage e StarterPlayer da cópia. Isso remove os 38 ModuleScripts e os dois bootstraps; nenhum carregador foi adicionado para repor a lógica.
- Excluídos os 2.469 `AttributesSerialize` de metadados personalizados. IDs/atributos originais continuam preservados no artefato anterior e no projeto. Nomes e hierarquia do cenário permanecem iguais.
- O código-fonte do RPG, dados, configurações e as entregas anteriores não foram alterados. Não foi criado ZIP desta cópia.

O programa `scripts/export_passive_scene.py` aceita somente o hash conhecido da origem, não executa código incorporado e exige classes nativas permitidas. Ele não é um desinfetador genérico de arquivos Roblox.

## Verificações realmente executadas

1. Parsing XML sem DOCTYPE/entidades e filtro com allowlist de classes. Código do exportador executado somente como transformação de dados; nenhum script do arquivo Roblox foi importado ou avaliado.
2. Zero Script/LocalScript/ModuleScript/PackageLink, Source/LinkedSource, BinaryString/SharedString/ProtectedString, Content/ContentId ou referências externas. As 151 URLs de fonte restantes são exclusivamente o recurso nativo `rbxasset://fonts/families/Guru.json`.
3. Comparação estrutural das subárvores retidas, antes e depois da exportação, excluindo somente `AttributesSerialize`. Hashes estruturais conferem; tamanhos, CFrames, materiais, cores e iluminação não foram simplificados.
4. Segunda revisão independente do arquivo final, sem importar/executar o exportador: **21.330 instâncias e 223.319 propriedades** iguais à origem, com as exclusões declaradas; 20.001 BaseParts inalteradas e manifesto coerente.
5. SHA-256 da origem novamente conferido após a transformação; original intacto. Parsing AST do novo Python, manifesto/JSON, hashes e links foram conferidos. Testes de gameplay não foram repetidos, pois o código de gameplay não foi alterado.

## Antivírus: tentativa e impedimento real

`clamscan`, `freshclam` e `MpCmdRun.exe` não estão instalados neste Linux. Não foram encontradas bases de assinaturas nas pastas padrão ou nas ferramentas do projeto. O índice Debian respondeu HTTP 200, mas o feed oficial `https://database.clamav.net/daily.cvd` foi bloqueado pelo proxy gerenciado com **CONNECT 403 Forbidden**. Não houve contorno desse bloqueio, instalação global ou varredura simulada com base vazia.

Logo, **`antivirus_scan_executed=false`**. Também não houve execução no Windows ou Roblox Studio. Nenhum arquivo foi submetido automaticamente a um serviço externo de análise. Mesmo uma varredura ClamAV não substituiria o veredicto do Defender; nenhuma alegação de arquivo seguro/falso positivo foi feita.

## Limite de uso

É somente um cenário passivo para inspeção no editor. O Terrain nativo já estava ausente na origem, e o preparador de Terrain foi removido junto com todo o código. **Não executar `PrepareStudio()` nesta cópia: o módulo não existe.** Não é o RPG jogável completo. O projeto com geradores e os metadados originais continuam preservados para retomada após a análise de segurança.

Se o Defender bloquear esta cópia, não restaure da quarentena para executá-la, não crie exclusões nem desative a proteção. Solicite a análise do artefato exato à [Microsoft](https://www.microsoft.com/en-us/wdsi/filesubmission), informando o hash acima, a URL, o registro e o nome completo da detecção. A causa dos alertas anteriores segue indeterminada em [MAP_DEFENDER_ALERT.md](MAP_DEFENDER_ALERT.md).
