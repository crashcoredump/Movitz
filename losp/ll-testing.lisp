;;;;------------------------------------------------------------------
;;;; 
;;;;    Copyright (C) 2005, 
;;;;    Department of Computer Science, University of Tromso, Norway.
;;;; 
;;;;    For distribution policy, see the accompanying file COPYING.
;;;; 
;;;; Filename:      ll-testing.lisp
;;;; Description:   low-level test code.
;;;; Author:        Frode Vatvedt Fjeld <frodef@acm.org>
;;;; Created at:    Thu Apr 14 08:18:43 2005
;;;;                
;;;; $Id: ll-testing.lisp,v 1.1 2005/04/15 07:03:09 ffjeld Exp $
;;;;                
;;;;------------------------------------------------------------------

(in-package muerte)

(defun dump-global-segment-table (&key table entries nofill)
  "Dump contents of the global (segment) descriptor table into a vector."
  (multiple-value-bind (gdt-base gdt-limit)
      (%sgdt)
    (let* ((gdt-entries (/ (1+ gdt-limit) 8))
	   (entries (or entries gdt-entries)))
      (check-type entries (integer 1 8192))
      (let ((table (or table
		       (make-array (* 2 entries)
				   :element-type '(unsigned-byte 32)
				   :initial-element 0))))
	(check-type table (vector (unsigned-byte 32)))
	(unless nofill
	  (loop for i upfrom 0 below (* 2 gdt-entries)
	      do (setf (aref table i)
		   (memref gdt-base 0 :index i :type :unsigned-byte32 :physicalp t))))
	table))))

(defun format-segment-table (table &key (start 0) (end (truncate (length table) 2)))
  (loop for i from start below end
      do (format t "~&~2D: base: #x~8,'0X, limit: #x~5,'0X, type-s-dpl-p: ~8,'0b, avl-x-db-g: ~4,'0b~%"
		 i
		 (segment-descriptor-base table i)
		 (segment-descriptor-limit table i)
		 (segment-descriptor-type-s-dpl-p table i)
		 (segment-descriptor-avl-x-db-g table i)))
  (values))