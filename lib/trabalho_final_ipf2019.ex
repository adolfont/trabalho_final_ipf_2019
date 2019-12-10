defmodule TrabalhoFinalIpf2019 do
  @moduledoc """
  Documentation for TrabalhoFinalIpf2019.
  """

  def obtem_stream(nome_arquivo) do
    File.stream!(nome_arquivo)
  end

  def troca_virgula_de_coeficiente_por_ponto(string) do
    String.replace(string, ~r/\"([0-9])\,([0-9])\"/, "\\1.\\2") |> String.trim()
  end

  def cria_lista_de_listas(nome_arquivo) do
    obtem_stream(nome_arquivo)
    |> Stream.map(fn line -> troca_virgula_de_coeficiente_por_ponto(line) end)
    |> processa_linha_a_linha()
  end

  def cria_mapas_alunos(lista_alunos) do
    [cabecalho | alunos] = lista_alunos

    alunos
    |> Enum.map(fn aluno -> Enum.zip(cabecalho, aluno) |> Map.new() end)
    |> processa_tempo_de_titulacao_em_dias()
  end

  def filtra_alunos_formados(lista_alunos) do
    lista_alunos
    |> Enum.filter(&(&1["Situação"] == "Formado"))
  end

  def filtra_alunos_desistentes(lista_alunos) do
    lista_alunos
    |> Enum.filter(&(&1["Situação"] == "Desistente"))
  end

  def calcula_sumario_aluno(lista_alunos) do
    lista_alunos = Enum.sort(lista_alunos, &( &1["Tempo detitulação"] <= &2["Tempo detitulação"] ))

    %{
      min: Enum.at(lista_alunos,0)["Tempo detitulação"],
      max: Enum.at(lista_alunos,length(lista_alunos)-1)["Tempo detitulação"],
      media: calcula_media(lista_alunos),
      mediana: calcula_mediana(lista_alunos)
    }
    
  end
  
  def calcula_mediana([]), do: 0 

  def calcula_mediana(lista_alunos) when rem( length(lista_alunos) , 2 ) == 1 do
    Enum.take(lista_alunos, div( length(lista_alunos) , 2 )) 
  end

  def calcula_mediana(lista_alunos) when rem( length(lista_alunos) , 2) == 0 do
    lista_alunos
    |> Enum.slice(div( length(lista_alunos) , 2 ) - 1, 2)
    |> calcula_media()
  end

  def calcula_media(lista_alunos) do
    Enum.reduce(lista_alunos, 0 , fn x, soma ->  x["Tempo detitulação"]  + soma end ) / length(lista_alunos)
  end

  def processa_linha_a_linha(stream) do
    stream |> Enum.map(fn x -> String.split(x, ",") end)
  end

  defp processa_tempo_de_titulacao_em_dias(lista_mapas) do
    lista_mapas
    |> Enum.map(fn aluno -> processa_tempo_titulacao_aluno(aluno) end)
  end
  
  defp processa_tempo_titulacao_aluno(aluno) do
    %{ aluno | "Tempo detitulação" => processa_campo_tempo_titulacao(aluno["Tempo detitulação"]) } 
  end

  defp processa_campo_tempo_titulacao(tempo_titulacao) do
    tempo_titulacao
    |> String.replace(~r/Mes\(es\)\ e | Dia\(s\)/, "")
    |> String.split(" ")
    |> calcula_tempo_titulacao_dias()
  end

  defp calcula_tempo_titulacao_dias([meses | [dias | _]]) do
    String.to_integer(meses) * 30 + String.to_integer(dias)
  end
end

TrabalhoFinalIpf2019.cria_lista_de_listas("AlunosPPGCA.csv")
|> TrabalhoFinalIpf2019.cria_mapas_alunos()
|> TrabalhoFinalIpf2019.filtra_alunos_formados()
|> TrabalhoFinalIpf2019.calcula_sumario_aluno()

# cabecalho = List.first(lista)

# um_aluno = List.last(lista)

# Enum.zip(cabecalho, um_aluno)
|> IO.inspect()
