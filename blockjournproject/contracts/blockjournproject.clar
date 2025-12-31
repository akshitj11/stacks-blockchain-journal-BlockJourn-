
(define-map journal
  (tuple (owner principal) (index uint))
  (tuple
    (content (string-utf8 1024)) ;; Allows entries up to 1024 characters
    (timestamp uint)
    (previous-hash (buff 32))   ;; A 32-byte buffer for a SHA256 hash
  )
)


(define-map user-entry-count principal uint)

;; --- Constants and Errors ---

(define-constant ERR-ENTRY-NOT-FOUND (err u100))

;; --- Public Functions (Callable by users) ---

;; Adds a new journal entry for the user calling the function.
;; The timestamp is now passed in as an argument to satisfy the checker.
(define-public (add-entry (content (string-utf8 1024)) (previous-hash (buff 32)) (timestamp uint))
  (let
    (
      (sender tx-sender)
      (new-index (+ (get-entry-count-internal sender) u1))
    )
    (begin
      (map-set journal
        (tuple (owner sender) (index new-index))
        (tuple
          (content content)
          (timestamp timestamp)
          (previous-hash previous-hash)
        )
      )
      (map-set user-entry-count sender new-index)
      (ok new-index)
    )
  )
)

;; --- Read-Only Functions (Viewable by anyone without a transaction) ---

;; Retrieves a specific journal entry for a given owner and index.
(define-read-only (get-entry (owner principal) (index uint))
  (map-get? journal (tuple (owner owner) (index index)))
)

;; Retrieves the total number of entries for a given owner.
(define-read-only (get-entry-count (owner principal))
  (ok (get-entry-count-internal owner))
)

;; --- Internal Helper Functions ---

;; A private helper to get a user's entry count, returning u0 if they have none.
(define-private (get-entry-count-internal (owner principal))
  (default-to u0 (map-get? user-entry-count owner))
)
