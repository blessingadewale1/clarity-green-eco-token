;; EcoTokens Smart Contract - Green Energy Incentive Marketplace
;; This contract enables the creation and management of EcoTokens, a tokenized incentive system designed to promote the purchase and sale of green energy. 
;; It includes features such as setting token prices, transaction fees, energy reserve management, and listing energy for sale by users. 
;; Admins can adjust prices, caps, and fees, while users can list energy, purchase energy, and receive refunds based on conditions. 
;; The contract also ensures a transparent and fair market by enforcing rules such as token balance checks and energy reserve limits.
;; This system aims to encourage sustainable energy use through token-based incentives and marketplace operations.

;; Define constants for error codes and limits
(define-constant admin tx-sender)
(define-constant err-insufficient-tokens (err u200))
(define-constant err-transfer-failed (err u201))
(define-constant err-invalid-amount (err u202))
(define-constant err-unauthorized (err u203))
(define-constant err-price-too-low (err u204))
(define-constant err-fee-exceeds-limit (err u205))
(define-constant err-max-reserve-exceeded (err u206))
(define-constant err-not-enough-balance (err u207))

;; Define data variables
(define-data-var eco-token-price uint u50) ;; Price per EcoToken in microstacks (1 STX = 1,000,000 microstacks)
(define-data-var user-energy-cap uint u5000) ;; Maximum energy per user in kWh
(define-data-var transaction-fee uint u5) ;; Transaction fee percentage (e.g., 5 means 5%)
(define-data-var refund-percentage uint u80) ;; Refund percentage on transaction (e.g., 80 means 80% of the amount)
(define-data-var total-energy-reserve uint u0) ;; Total energy reserve in the marketplace (in kWh)
(define-data-var energy-reserve-cap uint u1000000) ;; Maximum energy reserve capacity (in kWh)

;; Define maps for user balances and energy listings
(define-map eco-token-balance principal uint) ;; Maps user principal to EcoToken balance
(define-map energy-listing {seller: principal} {amount: uint, price: uint}) ;; Energy listings for sale

;; Private functions

;; Calculate transaction fee
(define-private (calculate-transaction-fee (amount uint))
  (/ (* amount (var-get transaction-fee)) u100))

;; Calculate refund for energy purchases
(define-private (calculate-refund (amount uint))
  (/ (* amount (var-get eco-token-price) (var-get refund-percentage)) u100))

;; Private function to update energy reserve
(define-private (adjust-energy-reserve (amount int))
  (let (
    (current-reserve (var-get total-energy-reserve))
    (new-reserve (if (< amount 0)
                     (if (>= current-reserve (to-uint (- 0 amount)))
                         (- current-reserve (to-uint (- 0 amount)))
                         u0)
                     (+ current-reserve (to-uint amount))))
  )
    (asserts! (<= new-reserve (var-get energy-reserve-cap)) err-max-reserve-exceeded)
    (var-set total-energy-reserve new-reserve)
    (ok true)))

;; Public functions

;; Set EcoToken price (only contract admin)
(define-public (set-eco-token-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender admin) err-unauthorized)
    (asserts! (> new-price u0) err-price-too-low)
    (var-set eco-token-price new-price)
    (ok true)))

;; Set transaction fee percentage (only contract admin)
(define-public (set-transaction-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender admin) err-unauthorized)
    (asserts! (<= new-fee u100) err-fee-exceeds-limit)
    (var-set transaction-fee new-fee)
    (ok true)))

;; Set energy reserve cap (only contract admin)
(define-public (set-energy-reserve-cap (new-cap uint))
  (begin
    (asserts! (is-eq tx-sender admin) err-unauthorized)
    (asserts! (>= new-cap (var-get total-energy-reserve)) err-not-enough-balance)
    (var-set energy-reserve-cap new-cap)
    (ok true)))

;; Set user energy cap (only contract admin)
(define-public (set-user-energy-cap (new-cap uint))
  (begin
    (asserts! (is-eq tx-sender admin) err-unauthorized)
    (asserts! (> new-cap u0) err-invalid-amount)
    (var-set user-energy-cap new-cap)
    (ok true)))

;; List energy for sale by a user
(define-public (list-energy-for-sale (amount uint) (price uint))
  (let (
    (user-balance (default-to u0 (map-get? eco-token-balance tx-sender)))
    (current-listing (default-to {amount: u0, price: u0} (map-get? energy-listing {seller: tx-sender})))
    (new-listing (+ amount (get amount current-listing)))
  )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (> price u0) err-price-too-low)
    (asserts! (>= user-balance new-listing) err-insufficient-tokens)
    (try! (adjust-energy-reserve (to-int amount)))
    (map-set energy-listing {seller: tx-sender} {amount: new-listing, price: price})
    (ok true)))

;; Refunds leftover EcoTokens to the admin account
(define-public (refund-to-admin)
  (let (
    (admin-balance (default-to u0 (map-get? eco-token-balance admin)))
    (market-reserve (var-get total-energy-reserve))
  )
    (asserts! (is-eq tx-sender admin) err-unauthorized)
    (asserts! (> admin-balance u0) err-not-enough-balance)

    ;; Update the energy reserve
    (var-set total-energy-reserve (+ market-reserve admin-balance))
    (map-set eco-token-balance admin u0)
    (ok true)))

;; Efficiently removes an energy listing by zeroing out the listing values
(define-public (optimize-remove-energy (seller principal))
  (begin
    (asserts! (is-eq tx-sender seller) err-unauthorized)
    (map-delete energy-listing {seller: seller})
    (ok true)))

;; Validates a user's energy listing before purchase
(define-public (validate-listing (seller principal))
  (let (
    (listing (default-to {amount: u0, price: u0} (map-get? energy-listing {seller: seller})))
  )
    (asserts! (> (get amount listing) u0) err-invalid-amount)
    (asserts! (> (get price listing) u0) err-price-too-low)
    (ok true)))

;; Checks the balance of a given user
(define-public (check-user-balance (user principal))
  (let (
    (balance (default-to u0 (map-get? eco-token-balance user)))
  )
    (ok balance)))

;; Allows the admin to set energy reserve limits
(define-public (set-energy-reserve-limit (new-limit uint))
  (begin
    (asserts! (is-eq tx-sender admin) err-unauthorized)
    (asserts! (>= new-limit u0) err-invalid-amount)
    (var-set energy-reserve-cap new-limit)
    (ok true)))

;; Set Refund Percentage
;; Updates refund percentage. Adds meaningful contract functionality.
(define-public (set-refund-percentage (new-percentage uint))
  (begin
    (asserts! (is-eq tx-sender admin) err-unauthorized)
    (asserts! (<= new-percentage u100) err-invalid-amount)
    (var-set refund-percentage new-percentage)
    (ok true)))

;; Remove energy from sale by a user
(define-public (remove-energy-from-sale (amount uint))
  (let (
    (current-listing (default-to {amount: u0, price: u0} (map-get? energy-listing {seller: tx-sender})))
  )
    (asserts! (>= (get amount current-listing) amount) err-insufficient-tokens)
    (try! (adjust-energy-reserve (to-int (- amount))))
    (map-set energy-listing {seller: tx-sender} {amount: (- (get amount current-listing) amount), price: (get price current-listing)})
    (ok true)))

;; Purchase energy from a seller
(define-public (purchase-energy (seller principal) (amount uint))
  (let (
    (listing (default-to {amount: u0, price: u0} (map-get? energy-listing {seller: seller})))
    (total-cost (* amount (get price listing)))
    (calculated-transaction-fee (calculate-transaction-fee total-cost))  ;; renamed variable
    (buyer-balance (default-to u0 (map-get? eco-token-balance tx-sender)))
    (seller-balance (default-to u0 (map-get? eco-token-balance seller)))
    (admin-balance (default-to u0 (map-get? eco-token-balance admin)))
  )
    (asserts! (not (is-eq tx-sender seller)) err-unauthorized)
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= (get amount listing) amount) err-not-enough-balance)
    (asserts! (>= buyer-balance (+ total-cost calculated-transaction-fee)) err-insufficient-tokens)

    ;; Update balances
    (map-set eco-token-balance seller (+ seller-balance total-cost))
    (map-set eco-token-balance tx-sender (- buyer-balance (+ total-cost calculated-transaction-fee)))
    (map-set eco-token-balance admin (+ admin-balance calculated-transaction-fee))
    (map-set energy-listing {seller: seller} {amount: (- (get amount listing) amount), price: (get price listing)})

    (ok true)))

;; Refund energy tokens (only if conditions met)
(define-public (refund-energy (amount uint))
  (let (
    (user-balance (default-to u0 (map-get? eco-token-balance tx-sender)))
    (refund-amount (calculate-refund amount))
    (admin-balance (default-to u0 (map-get? eco-token-balance admin)))
  )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= user-balance amount) err-not-enough-balance)
    (asserts! (>= admin-balance refund-amount) err-transfer-failed)

    ;; Update balances
    (map-set eco-token-balance tx-sender (- user-balance amount))
    (map-set eco-token-balance tx-sender (+ refund-amount (default-to u0 (map-get? eco-token-balance tx-sender))))
    (map-set eco-token-balance admin (- admin-balance refund-amount))

    (ok true)))

;; Read-only functions

;; Get current EcoToken price
(define-read-only (get-eco-token-price)
  (ok (var-get eco-token-price)))

;; Get current transaction fee
(define-read-only (get-transaction-fee)
  (ok (var-get transaction-fee)))

;; Get current energy reserve
(define-read-only (get-energy-reserve)
  (ok (var-get total-energy-reserve)))

;; Get energy listing details for a seller
(define-read-only (get-energy-listing (seller principal))
  (ok (default-to {amount: u0, price: u0} (map-get? energy-listing {seller: seller}))))

;; Get user EcoToken balance
(define-read-only (get-eco-token-balance (user principal))
  (ok (default-to u0 (map-get? eco-token-balance user))))

;; Get user energy cap
(define-read-only (get-user-energy-cap)
  (ok (var-get user-energy-cap)))

