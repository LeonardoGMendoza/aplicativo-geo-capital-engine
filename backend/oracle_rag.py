import os
import oci
import streamlit as st

@st.cache_data(ttl=600)
def gerar_recomendacao_rag(evento_nome, ativo_nome, distancia, visao):
    prompt_sistema = f"""
    Você é a IA de tomada de decisão do Omni-EcoRescue.
    
    DADOS DO EVENTO:
    - Desastre: {evento_nome}
    - Infraestrutura em risco: {ativo_nome}
    - Distância: {distancia:.0f} KM
    - Perfil Solicitante: {visao}
    
    INSTRUÇÃO:
    Se o perfil for "Corporativo (B2B)", retorne apenas uma recomendação de ação focada em mitigação de risco patrimonial e financeiro, em até 2 frases. Inicie com "**Decisão RAG (IA):**".
    Se o perfil for "Impacto Social / ESG (Comunidade)", retorne apenas uma recomendação focada em evacuação humanitária e suprimentos médicos, em até 2 frases. Inicie com "**Decisão RAG (IA):**".
    """

    try:
        compartment_id = os.environ.get("OCI_COMPARTMENT_ID")
        
        if not compartment_id:
            raise ValueError("Chave da Oracle não configurada. Ativando Fallback.")

        config = oci.config.from_file()
        genai_client = oci.generative_ai_inference.GenerativeAiInferenceClient(config=config)

        chat_request = oci.generative_ai_inference.models.CohereChatRequest(
            message=prompt_sistema,
            max_tokens=100,
            temperature=0.3
        )

        chat_detail = oci.generative_ai_inference.models.ChatDetails(
            compartment_id=compartment_id,
            serving_mode=oci.generative_ai_inference.models.OnDemandServingMode(
                model_id="cohere.command-a-03-2025"
            ),
            chat_request=chat_request
        )

        response = genai_client.chat(chat_detail)
        return response.data.chat_response.text

    except Exception as e:
        print(f"[Oracle RAG] Rodando em modo fallback - Falha ou OCI_COMPARTMENT_ID não configurado. Erro: {e}")
        if visao == "Corporativo (B2B)":
            return "**Decisão RAG (IA):** Interromper operação. O valor atual das ações no mercado amortiza perdas. Evitando dano estrutural bilionário."
        else:
            return "**Decisão RAG (IA):** Enviar kits de descontaminação e água potável. Acionar resgate humanitário prioritário para grupos vulneráveis."