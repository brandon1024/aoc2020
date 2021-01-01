#!/usr/bin/env -S guile -s
!#

(use-modules (ice-9 rdelim))
(use-modules (ice-9 format))
(use-modules (srfi srfi-1))
(use-modules (ice-9 receive))

(define seat-ids '())

(define (binary-search-seat-column boarding-pass lower upper next)
  (cond
	((> (string-length boarding-pass) 0)
	 (let ((c
			 (string-ref boarding-pass 0))
		   (s
			 (string-drop boarding-pass 1)))
	   (if (char=? c #\L)
		   (next s lower (+ (floor (/ (- upper lower) 2)) lower) next)
		   (next s (+ (ceiling (/ (- upper lower) 2)) lower) upper next))))
	(else lower)))

(define (binary-search-seat-id boarding-pass lower upper next)
  (cond
	((> (string-length boarding-pass) 3)
	 (let ((c
			 (string-ref boarding-pass 0))
		   (s
			 (string-drop boarding-pass 1)))
	   (if (char=? c #\F)
		   (next s lower (+ (floor (/ (- upper lower) 2)) lower) next)
		   (next s (+ (ceiling (/ (- upper lower) 2)) lower) upper next))))
	(else
	  (+ (* lower 8) (binary-search-seat-column boarding-pass 0 7 binary-search-seat-column)))))

(define (compute-seat-id boarding-pass)
  (binary-search-seat-id boarding-pass 0 127 binary-search-seat-id))

(define (aggregate-seat-ids seat-ids)
  (let ((aggregator (lambda (ids start end incr acc next)
					  (let ((partitioner (lambda (element)
										   (and (number? element)
												(and
												  (>= element start)
												  (< element (+ start 8)))))))
						(cond
						  ((and (> (length ids) 0) (< start end))
						   (receive (inside-partition outside-partition)
									(partition partitioner ids)
									(if (= (length inside-partition) 0)
										(next outside-partition (+ start incr) end incr acc next)
										(next outside-partition (+ start incr) end incr (cons inside-partition acc) next))))
						  (else acc))))))
	(aggregator seat-ids 0 1024 10 '() aggregator)))

(define (input-reader next)
  (let ((line (read-line)))
	(unless (eof-object? line)
	  (let ((current-seat-id (compute-seat-id line)))
		(set! seat-ids (append seat-ids (list current-seat-id))))
	  (next next))))

(define (part-one)
  (let* ((sorted-ids (sort seat-ids >))
		 (highest-seat-id (list-ref sorted-ids 0)))
	(format #t "[part 1]: highest seat id is ~d\n" highest-seat-id)))

(define (part-two)
  (let* ((sorted-ids (sort seat-ids >))
		 (aggregated-ids (aggregate-seat-ids sorted-ids))
		 (id-len (length aggregated-ids))
		 (new-ids (list-head (list-tail aggregated-ids 1) (- id-len 2)))
		 (my-seat-id 0))
	(let ((partitioner (lambda (x) (and (list? x) (< (length x) 8)))))
	  (receive (incomplete complete)
			   (partition partitioner new-ids)
			   (let ((sorted-ids (sort (list-ref incomplete 0) <))
					 (find-seat (lambda (seats expected next)
								  (if (= (list-ref seats 0) expected)
									  (next (list-tail seats 1) (+ 1 (list-ref seats 0)) next)
									  (format #t "[part 2]: my seat id is ~d\n" expected)))))
				 (find-seat sorted-ids (list-ref sorted-ids 0) find-seat))))))

(input-reader input-reader)
(part-one)
(part-two)

