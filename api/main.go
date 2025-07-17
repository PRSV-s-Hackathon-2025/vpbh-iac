package main

import (
	"context"
	"database/sql"
	"log"
	"net/http"
	"os"

	_ "github.com/ClickHouse/clickhouse-go/v2"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
)

type QueryRequest struct {
	Query string `json:"query" binding:"required"`
}

type QueryResponse struct {
	Data   []map[string]interface{} `json:"data"`
	Rows   int                      `json:"rows"`
	Status string                   `json:"status"`
}

func main() {
	clickhouseURL := os.Getenv("CLICKHOUSE_URL")
	if clickhouseURL == "" {
		clickhouseURL = "clickhouse://clickhouse-service:9000"
	}

	conn, err := sql.Open("clickhouse", clickhouseURL)
	if err != nil {
		log.Fatal("Failed to connect to ClickHouse:", err)
	}
	defer conn.Close()

	r := gin.Default()

	// Enable CORS
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"https://hackathon.awscloudclubs.com", "http://localhost:3000"},
		AllowMethods:     []string{"GET", "POST", "OPTIONS"},
		AllowHeaders:     []string{"*"},
		AllowCredentials: true,
	}))

	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "healthy"})
	})

	r.POST("/calculation", func(c *gin.Context) {
		var req QueryRequest
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		rows, err := conn.QueryContext(context.Background(), req.Query)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		defer rows.Close()

		columns, err := rows.Columns()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		var result []map[string]interface{}
		for rows.Next() {
			values := make([]interface{}, len(columns))
			valuePtrs := make([]interface{}, len(columns))
			for i := range columns {
				valuePtrs[i] = &values[i]
			}

			if err := rows.Scan(valuePtrs...); err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
				return
			}

			row := make(map[string]interface{})
			for i, col := range columns {
				row[col] = values[i]
			}
			result = append(result, row)
		}

		c.JSON(http.StatusOK, QueryResponse{
			Data:   result,
			Rows:   len(result),
			Status: "success",
		})
	})

	r.Run(":8080")
}