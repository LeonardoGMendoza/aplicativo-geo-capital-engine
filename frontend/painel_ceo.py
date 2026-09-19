import os
import sys

# Adiciona a raiz do projeto ao Python para ele achar a pasta 'backend'
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import streamlit as st
import requests
import yfinance as yf
import pandas as pd
import math
import time
from backend.oracle_rag import gerar_recomendacao_rag

st.set_page_config(page_title="Omni-Capital Engine", layout="wide", initial_sidebar_state="expanded")

@st.cache_data(ttl=600)
def buscar_cotacoes():
    # Tickers reais das maiores do mundo
    tickers = {
        "Brent (Petroleo)": "BZ=F",
        "ExxonMobil (EUA)": "XOM",
        "Chevron (EUA)": "CVX",
        "Shell (Europa)": "SHEL",
        "BP (Reino Unido)": "BP",
        "Vale (Brasil)": "VALE",
        "BHP (Australia)": "BHP",
        "Rio Tinto (UK)": "RIO",
        "Bunge (Agro)": "BG",
        "Raízen (Brasil)": "RAIZ4.SA"
    }
    precos = []
    for nome, t in tickers.items():
        try:
            ativo = yf.Ticker(t).history(period="1d")
            valor = ativo['Close'].iloc[-1]
            precos.append({"Empresa": nome, "Ticker": t, "Cotacao Atual": f"US$ {valor:.2f}" if "RAIZ" not in t else f"R$ {valor:.2f}"})
        except:
            precos.append({"Empresa": nome, "Ticker": t, "Cotacao Atual": "Mercado Fechado"})
    return pd.DataFrame(precos)

@st.cache_data(ttl=600)
def buscar_nasa():
    try:
        url = "https://eonet.gsfc.nasa.gov/api/v3/events?status=open&category=wildfires,severeStorms,earthquakes"
        return requests.get(url).json().get('events', [])
    except:
        return []

def calcular_distancia(lat1, lon1, lat2, lon2):
    R = 6371
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon/2)**2
    return R * (2 * math.atan2(math.sqrt(a), math.sqrt(1-a)))

st.sidebar.title("Configurações do Omni-EcoRescue")
visao = st.sidebar.radio("Selecione o Perfil de Usuário:", ["Corporativo (B2B)", "Impacto Social / ESG (Comunidade)"])

# Coordenadas realistas das gigantes globais + Contexto ESG
mapa_dados = [
    {"lat": 28.5, "lon": -90.0, "ativo": "Plataforma ExxonMobil (Golfo do Mexico)", "comunidade_vizinha": "Vila de Pescadores de Nova Orleans", "risco_secundario": "Vazamento Toxico (Oleoduto)"},
    {"lat": 29.0, "lon": -88.0, "ativo": "Plataforma Chevron (Golfo do Mexico)", "comunidade_vizinha": "Comunidades Costeiras (Louisiana)", "risco_secundario": "Contaminacao Hidrica (Oleoduto)"},
    {"lat": -23.8, "lon": -42.2, "ativo": "Plataforma Petrobras (Pre-Sal, Brasil)", "comunidade_vizinha": "Pescadores (Litoral de SP/RJ)", "risco_secundario": "Vazamento no Mar e Destruicao de Manguezal"},
    {"lat": -6.0, "lon": -50.1, "ativo": "Mina Carajas Vale (Brasil)", "comunidade_vizinha": "Comunidade Ribeirinha e Indigena", "risco_secundario": "Rompimento de Barragem e Risco de Colera"},
    {"lat": -21.2, "lon": -47.8, "ativo": "Usina Raízen (Sao Paulo)", "comunidade_vizinha": "Bairros Perifericos (Ribeirao Preto)", "risco_secundario": "Fumaca Toxica e Incendios em Lavouras"},
    {"lat": 21.5, "lon": -120.0, "ativo": "Navio Sonda BP (Pacifico)", "comunidade_vizinha": "Arquipelagos e Ilhas Costeiras", "risco_secundario": "Tsunami com lixo quimico"}
]
df_ativos = pd.DataFrame(mapa_dados)
df_cotacoes = buscar_cotacoes()
eventos_nasa = buscar_nasa()

if visao == "Corporativo (B2B)":
    st.title("🌐 Omni-EcoRescue - DASHBOARD CORPORATIVO")
    st.markdown("Monitoramento Aeroespacial de Ativos de Petróleo, Mineração e Agronegócio")
    st.markdown("---")
    
    col_mapa, col_ia = st.columns([3, 1])
    with col_mapa:
        st.subheader("🛰️ Radares Espaciais NASA vs Infraestrutura Global")
        st.map(df_ativos, zoom=1, color="#00ff00")
        
        st.subheader("📈 Mercado Financeiro em Tempo Real (Yahoo Finance)")
        st.dataframe(df_cotacoes, use_container_width=True)

    with col_ia:
        st.subheader("🤖 Assistente de Risco Operacional")
        alerta_disparado = False
        for ativo in mapa_dados:
            for evento in eventos_nasa[:50]:
                try:
                    lon_nasa, lat_nasa = evento['geometry'][-1].get('coordinates')
                except (KeyError, IndexError, TypeError):
                    continue
                dist = calcular_distancia(ativo['lat'], ativo['lon'], lat_nasa, lon_nasa)
                
                if dist < 600:
                    alerta_disparado = True
                    st.error(f"🚨 **PERIGO A ATIVOS DETECTADO**")
                    st.warning(f"**Gatilho:** {evento['title']}\n\n**Ativo:** {ativo['ativo']}\n\n**Distância:** {dist:.0f} KM")
                    st.markdown("### 🏭 ALERTA PATRIMONIAL")
                    texto_ia = gerar_recomendacao_rag(evento['title'], ativo['ativo'], dist, visao)
                    st.info(texto_ia)
                    
                    if st.button("ENVIAR ORDEM DE BLOQUEIO"):
                        st.success("✅ Ordem de Bloqueio enviada para a central de operacoes.")
                    break 
            if alerta_disparado:
                break
        if not alerta_disparado:
            st.success("✅ Nenhum ativo corporativo em risco.")

elif visao == "Impacto Social / ESG (Comunidade)":
    st.title("🛡️ Omni-EcoRescue - CENTRO DE COMANDO ESG")
    st.markdown("Prevenção Humanitária, Epidemiológica e Ambiental Pós-Desastre")
    st.markdown("---")
    
    col_mapa, col_ia = st.columns([3, 1])
    with col_mapa:
        st.subheader("🌍 Radares Espaciais NASA vs Zonas de Vulnerabilidade")
        # Mapa em vermelho para denotar alerta civil
        st.map(df_ativos, zoom=1, color="#ff0000")

    with col_ia:
        st.subheader("🤖 Assistente Humanitário (RAG)")
        alerta_disparado = False
        for ativo in mapa_dados:
            for evento in eventos_nasa[:50]:
                try:
                    lon_nasa, lat_nasa = evento['geometry'][-1].get('coordinates')
                except (KeyError, IndexError, TypeError):
                    continue
                dist = calcular_distancia(ativo['lat'], ativo['lon'], lat_nasa, lon_nasa)
                
                if dist < 600:
                    alerta_disparado = True
                    st.error(f"🚨 **EMERGÊNCIA SOCIAL DETECTADA**")
                    st.warning(f"**Desastre:** {evento['title']}\n\n**Zona Afetada:** Raio de {dist:.0f} KM do complexo industrial.")
                    st.markdown("### 🚑 PLANO DE SAÚDE PÚBLICA")
                    st.error(f"**Comunidade Ameaçada:** {ativo['comunidade_vizinha']}\n\n**Risco Secundário:** {ativo['risco_secundario']}")
                    texto_ia = gerar_recomendacao_rag(evento['title'], ativo['ativo'], dist, visao)
                    st.info(texto_ia)
                    
                    if st.button("ACIONAR LIDERANÇAS E ONGS"):
                        st.success("✅ Protocolos enviados para Associações Locais e ONGs.")
                    break 
            if alerta_disparado:
                break
        if not alerta_disparado:
            st.success("✅ Nenhuma comunidade em risco crítico.")
