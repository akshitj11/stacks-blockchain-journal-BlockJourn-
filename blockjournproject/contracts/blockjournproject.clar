
(define-map journal
  (tuple (owner principal) (index uint))
  (tuple
    (content (string-utf8 1024)) 
    (timestamp uint)
    (previous-hash (buff 32))   
  )
)


(define-map user-entry-count principal uint)

;; --- Constants and Errors ---

(define-constant ERR-ENTRY-NOT-FOUND (err u100))

;; --- Public Functions (Callable by users) ---


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



;; Retrieves a specific journal entry for a given owner and index.
(define-read-only (get-entry (owner principal) (index uint))
  (map-get? journal (tuple (owner owner) (index index)))
)

;; Retrieves the total number of entries for a given owner.
(define-read-only (get-entry-count (owner principal))
  (ok (get-entry-count-internal owner))
)



;; A private helper to get a user's entry count, returning u0 if they have none.
(define-private (get-entry-count-internal (owner principal))
  (default-to u0 (map-get? user-entry-count owner))
)
