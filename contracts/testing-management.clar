;; Testing Management Contract
;; Manages product testing phases and results

;; Constants
(define-constant ERR_UNAUTHORIZED (err u400))
(define-constant ERR_NOT_FOUND (err u401))
(define-constant ERR_INVALID_STATUS (err u402))
(define-constant ERR_INVALID_RESULT (err u403))

;; Data Variables
(define-data-var next-test-suite-id uint u1)
(define-data-var next-test-case-id uint u1)

;; Data Maps
(define-map test-suites
  { test-suite-id: uint }
  {
    project-id: uint,
    name: (string-ascii 100),
    test-type: (string-ascii 20),
    created-by: principal,
    creation-date: uint,
    status: (string-ascii 20),
    total-tests: uint,
    passed-tests: uint,
    failed-tests: uint
  }
)

(define-map test-cases
  { test-case-id: uint }
  {
    test-suite-id: uint,
    name: (string-ascii 100),
    description: (string-ascii 300),
    expected-result: (string-ascii 200),
    actual-result: (string-ascii 200),
    status: (string-ascii 20),
    executed-by: principal,
    execution-date: uint
  }
)

;; Public Functions

;; Create test suite for project
(define-public (create-test-suite (project-id uint) (name (string-ascii 100)) (test-type (string-ascii 20)))
  (let
    (
      (test-suite-id (var-get next-test-suite-id))
      (caller tx-sender)
    )
    ;; Check if caller is verified manager
    ;; Simplified validation - in production, implement proper manager verification
    ;; Manager verification would be implemented here in production

    ;; Check if project exists and is active
    ;; Simplified validation - assume project exists
    (asserts! (> project-id u0) ERR_NOT_FOUND)

    (map-set test-suites
      { test-suite-id: test-suite-id }
      {
        project-id: project-id,
        name: name,
        test-type: test-type,
        created-by: caller,
        creation-date: block-height,
        status: "created",
        total-tests: u0,
        passed-tests: u0,
        failed-tests: u0
      }
    )

    (var-set next-test-suite-id (+ test-suite-id u1))
    (ok test-suite-id)
  )
)

;; Add test case to suite
(define-public (add-test-case (test-suite-id uint) (name (string-ascii 100)) (description (string-ascii 300)) (expected-result (string-ascii 200)))
  (let
    (
      (test-case-id (var-get next-test-case-id))
      (caller tx-sender)
    )
    ;; Check if caller is verified manager
    ;; Simplified validation - in production, implement proper manager verification
    ;; Manager verification would be implemented here in production

    ;; Check if test suite exists
    (asserts! (is-some (map-get? test-suites { test-suite-id: test-suite-id })) ERR_NOT_FOUND)

    (map-set test-cases
      { test-case-id: test-case-id }
      {
        test-suite-id: test-suite-id,
        name: name,
        description: description,
        expected-result: expected-result,
        actual-result: "",
        status: "pending",
        executed-by: caller,
        execution-date: u0
      }
    )

    ;; Update test suite total count
    (match (map-get? test-suites { test-suite-id: test-suite-id })
      suite-data
      (map-set test-suites
        { test-suite-id: test-suite-id }
        (merge suite-data { total-tests: (+ (get total-tests suite-data) u1) })
      )
      false
    )

    (var-set next-test-case-id (+ test-case-id u1))
    (ok test-case-id)
  )
)

;; Execute test case
(define-public (execute-test-case (test-case-id uint) (actual-result (string-ascii 200)) (passed bool))
  (let
    (
      (caller tx-sender)
    )
    ;; Check if caller is verified manager
    ;; Simplified validation - in production, implement proper manager verification
    ;; Manager verification would be implemented here in production

    (match (map-get? test-cases { test-case-id: test-case-id })
      test-case-data
      (let
        (
          (test-suite-id (get test-suite-id test-case-data))
          (new-status (if passed "passed" "failed"))
        )
        ;; Update test case
        (map-set test-cases
          { test-case-id: test-case-id }
          (merge test-case-data {
            actual-result: actual-result,
            status: new-status,
            executed-by: caller,
            execution-date: block-height
          })
        )

        ;; Update test suite counts
        (match (map-get? test-suites { test-suite-id: test-suite-id })
          suite-data
          (let
            (
              (new-passed (if passed (+ (get passed-tests suite-data) u1) (get passed-tests suite-data)))
              (new-failed (if passed (get failed-tests suite-data) (+ (get failed-tests suite-data) u1)))
            )
            (map-set test-suites
              { test-suite-id: test-suite-id }
              (merge suite-data {
                passed-tests: new-passed,
                failed-tests: new-failed
              })
            )
            (ok true)
          )
          ERR_NOT_FOUND
        )
      )
      ERR_NOT_FOUND
    )
  )
)

;; Complete test suite
(define-public (complete-test-suite (test-suite-id uint))
  (let
    (
      (caller tx-sender)
    )
    ;; Check if caller is verified manager
    ;; Simplified validation - in production, implement proper manager verification
    ;; Manager verification would be implemented here in production

    (match (map-get? test-suites { test-suite-id: test-suite-id })
      suite-data
      (begin
        (map-set test-suites
          { test-suite-id: test-suite-id }
          (merge suite-data { status: "completed" })
        )
        (ok true)
      )
      ERR_NOT_FOUND
    )
  )
)

;; Read-only Functions

;; Get test suite details
(define-read-only (get-test-suite (test-suite-id uint))
  (map-get? test-suites { test-suite-id: test-suite-id })
)

;; Get test case details
(define-read-only (get-test-case (test-case-id uint))
  (map-get? test-cases { test-case-id: test-case-id })
)

;; Get test suite pass rate
(define-read-only (get-pass-rate (test-suite-id uint))
  (match (map-get? test-suites { test-suite-id: test-suite-id })
    suite-data
    (let
      (
        (total (get total-tests suite-data))
        (passed (get passed-tests suite-data))
      )
      (if (> total u0)
        (some (/ (* passed u100) total))
        none
      )
    )
    none
  )
)
