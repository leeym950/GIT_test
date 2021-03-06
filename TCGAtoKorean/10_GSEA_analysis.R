##
## 10. GSEA analysis
##
##
##

if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
if(!require(fgsea)) BiocManager::install("fgsea")
if(!require(qusage)) BiocManager::install("qusage")
if(!require(ggplot2)) install.packages("ggplot2")
if(!require(dplyr)) install.packages("dplyr")
library(fgsea)
library(qusage)
library(ggplot2)
library(dplyr)
library(GSEABase)

# Create ranks
gseaDat <- resultAB
gsea.ranks <- gseaDat[ ,"log2FoldChange"]
names(gsea.ranks) <- row.names(gseaDat)

barplot(sort(gsea.ranks, decreasing=T))

# Load pathways
#pathway <- read.gmt("D:/LYM/Projects/Data/h.all.v7.0.symbols.gmt")           # Cancer Hallmarks
pathway <- read.gmt("D:/LYM/Projects/Data/c2.all.v7.0.symbols.gmt")          # Curated genes: all
#pathway <- read.gmt("D:/LYM/Projects/Data/c2.cp.reactome.v7.0.symbols.gmt")  # Curated genes: reactome
#pathway <- read.gmt("D:/LYM/Projects/Data/c6.all.v7.0.symbols.gmt")          # Oncogenic signature
#pathway <- read.gmt("D:/LYM/Projects/Data/c7.all.v7.0.symbols.gmt")          # Immunologic signature


# Conduct analysis
gsea.result <- fgsea(pathway, gsea.ranks, minSize=15, maxSize=500, nperm=1000)

head(gsea.result[order(padj, -abs(NES)),], n=10) # top 10 results

# # Save tableplot
# # png(filename="tableplot_immune.png", width=1000, height=14000)
# ggplot(bg="white")
# topUp <- gsea.result %>% filter(ES > 0) %>% top_n(n=10, wt=-padj)
# topDown <- gsea.result %>% filter(ES < 0) %>% top_n(n=10, wt=-padj)
# topPathways <- bind_rows(topUp, topDown) %>%  arrange(-ES)
# plotGseaTable(pathway[topPathways$pathway], 
#               gsea.ranks[complete.cases(gsea.ranks)], 
#               gsea.result, 
#               gseaParam = 0.5)
# # dev.off()

# Show in a nice table:
if(!require(DT)) install.packages("DT")
library(DT)

gsea.result %>% 
  dplyr::select(-leadingEdge, -ES, -nMoreExtreme) %>% 
  arrange(padj) %>% 
  DT::datatable()

# png(filename="D:/rectalNMF/Hallmark.png")
ggplot(bg="white")
ggplot(gsea.result, aes(reorder(pathway, NES), NES)) +
  geom_col(aes(fill=padj<0.05)) +
  coord_flip() +
  labs(x="Pathway", y="Normalized Enrichment Score",
       title="Hallmark pathways NES from GSEA") + 
  theme_minimal()
# dev.off()s

# ## KEGG pathway analysis
# if(!require(clusterProfiler)) BiocManager::install("clusterProfiler")
# library(clusterProfiler)
# 
# search_kegg_organism('hsa', by='kegg_code') #hsa for homo sapiens
# 
# gseaDat2 <- replaceGeneId(gseaDat, id.in="symbol", id.out="entrez") # replace gene ID from Ensembl ID to HUGO symbol
# sigGenes <- row.names(gseaDat2)[ gseaDat2[ ,"padj"] < 0.05 &  !is.na(gseaDat2[ ,"padj"]) & abs(gseaDat2[ ,"log2FoldChange"]) > 1 ]
# sigGenes <- na.exclude(sigGenes)
# kk <- enrichKEGG(gene=sigGenes, organism="hsa")
# head(kk, n=10)
# 
# browseKEGG(kk, 'hsa04020')
