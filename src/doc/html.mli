type media_value =
  | Media_all
  | Media_aural
  | Media_braille
  | Media_handheld
  | Media_projection
  | Media_print
  | Media_screen
  | Media_tty
  | Media_tv
  | Media_min_width  of string
  | Media_max_width  of string
  | Media_width      of string
  | Media_min_height of string
  | Media_max_height of string
  | Media_height     of string

type media =
  | Media_or  of media * media
  | Media_and of media * media
  | Media_not of media
  | Media_val of media_value

type rel_value =
  | Rel_icon
  | Rel_stylesheet
  (* Are the others necessary? *)

type link
val link : ?href:  string ->
           ?media: media ->
           ?mimetype: string ->
           rel:    rel_value ->
           unit -> link

type head
val head : (* ?styles: style list -> *)
           (* ?base: ? -> *)
           ?links: link list ->
           (* ?metas: meta list -> *)
           (* ?scripts: scrupt list -> *)
           (* ?noscripts? *)
           title: string ->
           unit -> head

type flow
type phrasing

type table
type tablebody
type tablerow

type 'a body
type ('a,'b,'c,'d) element
type ('a,'b,'c,'d) k = ('a, 'b, 'c, 'd) element -> 'a
type 'a gentag = ?accesskey: char ->
                 ?classes: string ->
                 ?contenteditable: bool -> 'a

(*** Some types to see clearer *)

(** The only important types are 'c, content model of the tag, *)
(** and 'd, content model of its parent  *)
type ('a,'b,'c,'d) tag = ?id: string ->
  (('a, 'b, 'c, 'd) element -> 'a) gentag

(** 'b is the content model of the parent *)
type ('a,'b,'c) void_tag = ?id: string ->
  (unit -> (('a, 'b, 'c, 'b) k, 'b, 'c, 'b) element) gentag

type target =
  | Target_blank
  | Target_parent
  | Target_self
  | Target_top

type preload_behavior =
  | Preload_none
  | Preload_metadata
  | Preload_auto

(* Text (normal character data) *)
val text : string -> (('a, 'b, 'c, 'd) k, 'b, 'c, 'd) element

(* All tags (flow and phrasing mixed) *)
val a : ?href: string ->
        ?download: string ->
        ?target: target ->
        ('a, 'b, 'c, 'c) tag
val abbr : ?title: string -> ('a, 'b, phrasing, phrasing) tag
val address : ('a, 'b, flow, flow) tag
val article : ('a, 'b, flow, flow) tag
val aside : ('a, 'b, flow, flow) tag
val audio : ?autoplay: bool ->
            ?preload: preload_behavior ->
            ?controls : bool ->
            ?loop : bool ->
            ?mediagroup : string ->
            ?muted : bool ->
            ?src : string ->
            ('a, 'b, 'c, 'c) tag
val b : ('a, 'b, phrasing, phrasing) tag
val blockquote : ?cite: string -> ('a, 'b, flow, flow) tag
val br : ('a, 'b, 'c) void_tag
val hr : ('a, 'b, flow) void_tag
val canvas : ?height: string ->
             ?width: string ->
             ('a, 'b, 'c, 'c) tag
val cite : ('a, 'b, phrasing, phrasing) tag
val figure : ('a, 'b, flow, flow) tag
val pre : ('a, 'b, phrasing, flow) tag
val code : ('a, 'b, phrasing, phrasing) tag
val div : ('a, 'b, flow, 'c) tag
val span : ('a, 'b, flow, 'c) tag
val em : ('a, 'b, phrasing, phrasing) tag
val footer : ('a, 'b, flow, flow) tag
val h1 : ('a, 'b, phrasing, flow) tag
val h2 : ('a, 'b, phrasing, flow) tag
val h3 : ('a, 'b, phrasing, flow) tag
val h4 : ('a, 'b, phrasing, flow) tag
val h5 : ('a, 'b, phrasing, flow) tag
val h5 : ('a, 'b, phrasing, flow) tag
val p : ('a, 'b, phrasing, flow) tag
val main : ('a, 'b, flow, flow) tag
val nav : ('a, 'b, flow, flow) tag
val close : ((('a, 'b, 'c, 'd) k, 'b, 'c, 'd) element, 'h, 'h, 'b) element

val table : ('a, 'b, table, flow) tag
val tbody : ('a, 'b, tablebody, table) tag
val tr : ('a, 'b, tablerow, tablebody) tag
val td : ('a, 'b, flow, tablerow) tag

val body : ('a, 'b, flow, flow) tag
val body_end : (flow body, flow, 'c, 'd) element

type html
val html : head -> flow body -> html

val export : html -> string
