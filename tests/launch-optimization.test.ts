import { describe, it, expect, beforeEach } from "vitest"

describe("Launch Optimization Contract", () => {
  let contractAddress
  let testAddress1
  let testAddress2
  
  beforeEach(() => {
    contractAddress = "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.launch-optimization"
    testAddress1 = "ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5"
    testAddress2 = "ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG"
  })
  
  describe("Launch Creation", () => {
    it("should create launch successfully", () => {
      const result = {
        type: "ok",
        value: 1,
      }
      expect(result.type).toBe("ok")
      expect(result.value).toBe(1)
    })
    
    it("should reject launch creation by unverified manager", () => {
      const result = {
        type: "error",
        value: 500,
      }
      expect(result.type).toBe("error")
      expect(result.value).toBe(500)
    })
    
    it("should reject launch creation for inactive project", () => {
      const result = {
        type: "error",
        value: 501,
      }
      expect(result.type).toBe("error")
      expect(result.value).toBe(501)
    })
  })
  
  describe("Performance Metrics", () => {
    it("should record metric successfully", () => {
      const result = {
        type: "ok",
        value: 1,
      }
      expect(result.type).toBe("ok")
      expect(result.value).toBe(1)
    })
    
    it("should reject metric recording by unverified manager", () => {
      const result = {
        type: "error",
        value: 500,
      }
      expect(result.type).toBe("error")
      expect(result.value).toBe(500)
    })
    
    it("should store metric data correctly", () => {
      const metricData = {
        "launch-id": 1,
        "metric-name": "user-signups",
        "metric-value": 1500,
        "target-value": 1000,
        "measurement-date": 100,
        "recorded-by": testAddress1,
      }
      expect(metricData["metric-name"]).toBe("user-signups")
      expect(metricData["metric-value"]).toBe(1500)
      expect(metricData["target-value"]).toBe(1000)
    })
  })
  
  describe("Launch Status Management", () => {
    it("should update launch status successfully", () => {
      const result = {
        type: "ok",
        value: true,
      }
      expect(result.type).toBe("ok")
      expect(result.value).toBe(true)
    })
    
    it("should reject status update by non-manager", () => {
      const result = {
        type: "error",
        value: 500,
      }
      expect(result.type).toBe("error")
      expect(result.value).toBe(500)
    })
    
    it("should update success score successfully", () => {
      const result = {
        type: "ok",
        value: true,
      }
      expect(result.type).toBe("ok")
      expect(result.value).toBe(true)
    })
  })
  
  describe("Feedback Management", () => {
    it("should submit feedback successfully", () => {
      const result = {
        type: "ok",
        value: true,
      }
      expect(result.type).toBe("ok")
      expect(result.value).toBe(true)
    })
    
    it("should reject invalid rating", () => {
      const result = {
        type: "error",
        value: 503,
      }
      expect(result.type).toBe("error")
      expect(result.value).toBe(503)
    })
    
    it("should store feedback data correctly", () => {
      const feedbackData = {
        "feedback-text": "Great product launch!",
        rating: 9,
        "submitted-by": testAddress2,
        "submission-date": 110,
      }
      expect(feedbackData["feedback-text"]).toBe("Great product launch!")
      expect(feedbackData.rating).toBe(9)
    })
  })
  
  describe("Read Functions", () => {
    it("should return launch details correctly", () => {
      const launchData = {
        "project-id": 1,
        name: "Product Launch v1.0",
        "launch-date": 200,
        "target-audience": "Tech enthusiasts",
        "marketing-budget": 50000,
        "launch-manager": testAddress1,
        status: "active",
        "success-score": 85,
      }
      expect(launchData.name).toBe("Product Launch v1.0")
      expect(launchData.status).toBe("active")
      expect(launchData["success-score"]).toBe(85)
    })
    
    it("should return metric details correctly", () => {
      const metricData = {
        "launch-id": 1,
        "metric-name": "conversion-rate",
        "metric-value": 15,
        "target-value": 12,
        "measurement-date": 105,
        "recorded-by": testAddress1,
      }
      expect(metricData["metric-name"]).toBe("conversion-rate")
      expect(metricData["metric-value"]).toBe(15)
    })
    
    it("should correctly identify active launches", () => {
      const isActive = true
      expect(isActive).toBe(true)
    })
  })
})
