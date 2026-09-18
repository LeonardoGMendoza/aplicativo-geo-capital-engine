cat > README.md << 'EOF'
# Omni-EcoRescue

Sistema preditivo que cruza dados de desastres da NASA com ativos industriais globais (plataformas offshore, mineracao, agronegocio) para prevenir perdas corporativas e proteger comunidades vizinhas em risco.

Projeto desenvolvido para o Hackathon "Tech for Change".

---

## O Problema

Desastres climaticos severos atingem infraestruturas industriais criticas. A falta de precisao na tomada de decisao gera duas consequencias:

- Dano Corporativo: perda estrutural e desvalorizacao de ativos.
- Dano Social: comunidades vizinhas (pescadores, ribeirinhos) afetadas por riscos secundarios (vazamentos, contaminacao) sem tempo habil para evacuacao.

## A Solucao

Painel dual que apresenta, para o mesmo evento de risco, duas perspectivas:

- Visao Corporativa (B2B): cruza a localizacao do evento (NASA EONET) com o valor de mercado do ativo (Yahoo Finance) e recomenda acao de mitigacao.
- Visao de Impacto Social (ESG/Comunidade): identifica a comunidade vizinha ao ativo e recomenda protocolo de evacuacao/suporte humanitario.

Em ambas as visoes, o sistema recomenda -- a decisao final e o acionamento de qualquer acao sao sempre confirmados por um humano, via botao no painel (Human-in-the-Loop).

## Estudo de Caso

Bacia de Campos (RJ) -- infraestrutura da Petrobras e Colonia de Pescadores Z3 de Macae, que ja possui vinculo formal com a Petrobras via Plano de Compensacao Ambiental exigido pelo IBAMA.

## Arquitetura

| Camada | Tecnologia |
|---|---|
| Frontend | Streamlit (frontend/painel_ceo.py) |
| Calculo de risco geoespacial | math (formula de Haversine, raio de 600 km) |
| Dados de desastres | NASA EONET (tempo real) |
| Dados de mercado | Yahoo Finance (yfinance) |
| Inteligencia Artificial | Oracle OCI Generative AI (cohere.command-r-plus), com fallback local seguro |

## Como rodar localmente

```bash
# 1. Instalar dependencias
pip install streamlit requests yfinance pandas oci

# 2. Rodar o painel (a partir da pasta raiz do projeto)
streamlit run frontend/painel_ceo.py
```

O app abre em http://localhost:8501.

### Integracao com Oracle (opcional)

O motor de recomendacao (backend/oracle_rag.py) funciona em dois modos:

- Real: requer o SDK oci instalado e a variavel de ambiente OCI_COMPARTMENT_ID configurada, alem do arquivo de credenciais ~/.oci/config.
- Fallback (padrao): se a credencial nao estiver configurada, o sistema usa uma recomendacao local pre-definida, mantendo o painel estavel em demonstracoes publicas.

## Documentacao completa

Ver docs/documentacao_oficial_pitch.md para a documentacao oficial do projeto, incluindo a base legal (CONAMA/EIA-RIMA) e o modelo de negocio detalhado.

## Status do projeto (MVP de Hackathon)

- [OK] Calculo de risco geoespacial funcional
- [OK] Integracao real com NASA EONET e Yahoo Finance
- [OK] Human-in-the-Loop implementado (toda acao exige confirmacao humana)
- [EM ANDAMENTO] Integracao com Oracle GenAI: implementada, sujeita a fallback conforme disponibilidade de credencial
- [EM ANDAMENTO] Scripts em backend/central_executiva.py e backend/omni_engine_alertas.py sao provas de conceito isoladas, nao conectadas ao painel principal

## Autores

Equipe do Hackathon "Tech for Change" -- 2026.
EOF