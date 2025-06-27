;; Launch Optimization Contract
;; Optimizes product launches and tracks performance

;; Constants
(define-constant ERR_UNAUTHORIZED (err u500))
(define-constant ERR_NOT_FOUND (err u501))
(define-constant ERR_INVALID_STATUS (err u502))
(define-constant ERR_INVALID_METRIC (err u503))

;; Data Variables
(define-data-var next-launch-id uint u1)
(define-data-var next-metric-id uint u1)

;; Data Maps
(define-map launches
  { launch-id: uint }
  {
    project-id: uint,
    name: (string-ascii 100),
    launch-date: uint,
    target-audience: (string-ascii 100),
    marketing-budget: uint,
    launch-manager: principal,
    status: (string-ascii 20),
    success-score: uint
  }
)

(define-map performance-metrics
  { metric-id: uint }
  {
    launch-id: uint,
    metric-name: (string-ascii 50),
    metric-value: uint,
    target-value: uint,
    measurement-date: uint,
    recorded-by: principal
  }
)

(define-map launch-feedback
  { launch-id: uint, feedback-id: uint }
  {
    feedback-text: (string-ascii 300),
    rating: uint,
    submitted-by: principal,
    submission-date: uint
  }
)

;; Public Functions

;; Create product launch
(define-public (create-launch (project-id uint) (name (string-ascii 100)) (launch-date uint) (target-audience (string-ascii 100)) (marketing-budget uint))
  (let
    (
      (launch-id (var-get next-launch-id))
      (caller tx-sender)
    )
    ;; Check if caller is verified manager
    ;; Simplified validation - in production, implement proper manager verification
    ;; Manager verification would be implemented here in production

    ;; Check if project exists and is active
    ;; Simplified validation - assume project exists
    (asserts! (> project-id u0) ERR_NOT_FOUND)

    (map-set launches
      { launch-id: launch-id }
      {
        project-id: project-id,
        name: name,
        launch-date: launch-date,
        target-audience: target-audience,
        marketing-budget: marketing-budget,
        launch-manager: caller,
        status: "planned",
        success-score: u0
      }
    )

    (var-set next-launch-id (+ launch-id u1))
    (ok launch-id)
  )
)

;; Record performance metric
(define-public (record-metric (launch-id uint) (metric-name (string-ascii 50)) (metric-value uint) (target-value uint))
  (let
    (
      (metric-id (var-get next-metric-id))
      (caller tx-sender)
    )
    ;; Check if caller is verified manager
    ;; Simplified validation - in production, implement proper manager verification
    ;; Manager verification would be implemented here in production

    ;; Check if launch exists
    (asserts! (is-some (map-get? launches { launch-id: launch-id })) ERR_NOT_FOUND)

    (map-set performance-metrics
      { metric-id: metric-id }
      {
        launch-id: launch-id,
        metric-name: metric-name,
        metric-value: metric-value,
        target-value: target-value,
        measurement-date: block-height,
        recorded-by: caller
      }
    )

    (var-set next-metric-id (+ metric-id u1))
    (ok metric-id)
  )
)

;; Update launch status
(define-public (update-launch-status (launch-id uint) (new-status (string-ascii 20)))
  (let
    (
      (caller tx-sender)
    )
    (match (map-get? launches { launch-id: launch-id })
      launch-data
      (begin
        (asserts! (is-eq caller (get launch-manager launch-data)) ERR_UNAUTHORIZED)

        (map-set launches
          { launch-id: launch-id }
          (merge launch-data { status: new-status })
        )
        (ok true)
      )
      ERR_NOT_FOUND
    )
  )
)

;; Calculate and update success score
(define-public (update-success-score (launch-id uint) (score uint))
  (let
    (
      (caller tx-sender)
    )
    ;; Check if caller is verified manager
    ;; Simplified validation - in production, implement proper manager verification
    ;; Manager verification would be implemented here in production

    (match (map-get? launches { launch-id: launch-id })
      launch-data
      (begin
        (map-set launches
          { launch-id: launch-id }
          (merge launch-data { success-score: score })
        )
        (ok true)
      )
      ERR_NOT_FOUND
    )
  )
)

;; Submit launch feedback
(define-public (submit-feedback (launch-id uint) (feedback-id uint) (feedback-text (string-ascii 300)) (rating uint))
  (let
    (
      (caller tx-sender)
    )
    ;; Check if launch exists
    (asserts! (is-some (map-get? launches { launch-id: launch-id })) ERR_NOT_FOUND)

    ;; Validate rating (1-10 scale)
    (asserts! (and (>= rating u1) (<= rating u10)) ERR_INVALID_METRIC)

    (map-set launch-feedback
      { launch-id: launch-id, feedback-id: feedback-id }
      {
        feedback-text: feedback-text,
        rating: rating,
        submitted-by: caller,
        submission-date: block-height
      }
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get launch details
(define-read-only (get-launch (launch-id uint))
  (map-get? launches { launch-id: launch-id })
)

;; Get performance metric
(define-read-only (get-metric (metric-id uint))
  (map-get? performance-metrics { metric-id: metric-id })
)

;; Get launch feedback
(define-read-only (get-feedback (launch-id uint) (feedback-id uint))
  (map-get? launch-feedback { launch-id: launch-id, feedback-id: feedback-id })
)

;; Check if launch is active
(define-read-only (is-launch-active (launch-id uint))
  (match (map-get? launches { launch-id: launch-id })
    launch-data
    (is-eq (get status launch-data) "active")
    false
  )
)
