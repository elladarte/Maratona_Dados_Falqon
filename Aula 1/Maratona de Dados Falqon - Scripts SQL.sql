-- Prática 01

	SELECT 
		LOJA_ID as CodLoja,
		DT_EMISSAO as DataEmissao,
		COUNT(DISTINCT CUPOM) as Cupons,
		AVG(DESCONTO) as DescontoPerc
	FROM NF_SAIDA
	WHERE 
		CANCELADO = 0
		AND DT_EMISSAO BETWEEN '09/10/2019' AND '12/10/2019'
	GROUP BY LOJA_ID, DT_EMISSAO



-- Prática 02: Quantos produtos foram vendidos em Junho de 2019 por Plataforma e Acessórios

	SELECT
		p.Plataforma		as Plataforma,
		p.Grupo				as Grupo,
		SUM(ns.QUANTIDADE)	as Quantidade
	FROM NF_SAIDA ns
	LEFT JOIN
		(
			SELECT 
				a.ID,
				b.DESCRICAO Plataforma,
				c.DESCRICAO Grupo
			FROM PRODUTOS a
			LEFT JOIN PLATAFORMA_PRODUTO b
			ON a.PLATAFORMA_ID like b.ID
			LEFT JOIN GRUPO_PRODUTO c
			ON a.GRUPO_ID like c.ID
		) p
	ON ns.PRODUTO_ID like p.ID
	WHERE ns.DT_EMISSAO BETWEEN '01/06/2019' and '30/06/2019'
	GROUP BY p.Grupo, p.Plataforma
	ORDER BY Plataforma,Grupo ASC


-- View CupomVolume

CREATE VIEW CuponsVolume as 

	SELECT
		CONVERT(CHAR(4), ns.DT_EMISSAO, 100) + CONVERT(CHAR(4), ns.DT_EMISSAO, 120) as [Mês Ano],
		p.Plataforma				as Plataforma,
		COUNT(DISTINCT ns.CUPOM)	as Cupons,
		SUM(ns.QUANTIDADE)			as Quantidade
	FROM NF_SAIDA ns
	LEFT JOIN
		(
			SELECT 
				a.ID,
				b.DESCRICAO Plataforma
			FROM PRODUTOS a
			LEFT JOIN PLATAFORMA_PRODUTO b
			ON a.PLATAFORMA_ID like b.ID
		) p
	ON ns.PRODUTO_ID like p.ID
	WHERE ns.CANCELADO = 0
	GROUP BY p.Plataforma, CONVERT(CHAR(4), ns.DT_EMISSAO, 100) + CONVERT(CHAR(4), ns.DT_EMISSAO, 120)



-- View Venda Loja: Crie uma view que possa retornar o valor de venda e quantidade vendida por Mês Ano, Loja e Grupo

CREATE VIEW VendaLoja as

	SELECT
		e.DESCRICAO as Loja,
		x.Grupo as Grupo,
		CONVERT(CHAR(4), ns.DT_EMISSAO, 100) + CONVERT(CHAR(4), ns.DT_EMISSAO, 120) as [Mês Ano],
		SUM(p.VALOR * ns.QUANTIDADE) as Venda,
		SUM(ns.QUANTIDADE) as Quantidade
	FROM NF_SAIDA ns
	LEFT JOIN PRECO p
	ON ns.PRODUTO_ID = p.PRODUTO_ID and ns.LOJA_ID = p.LOJA_ID
	LEFT JOIN ESTABELECIMENTOS e
	ON ns.LOJA_ID = e.ID
	LEFT JOIN
	(
		SELECT 
			PRODUTOS.ID,
			GRUPO_PRODUTO.DESCRICAO Grupo
		FROM PRODUTOS
		LEFT JOIN GRUPO_PRODUTO
		ON  PRODUTOS.GRUPO_ID = GRUPO_PRODUTO.ID
	) x
	on ns.PRODUTO_ID = x.ID
	WHERE ns.CANCELADO = 0
	GROUP BY CONVERT(CHAR(4), ns.DT_EMISSAO, 100) + CONVERT(CHAR(4), ns.DT_EMISSAO, 120), e.DESCRICAO, x.Grupo