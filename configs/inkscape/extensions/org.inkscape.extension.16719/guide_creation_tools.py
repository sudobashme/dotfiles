#!/usr/bin/env python
# coding=utf-8
#
# Copyright (C) 2008 Jonas Termeau <jonas.termeau **AT** gmail.com>
#               2019-2025 Maren Hachmann <marenhachmann@yahoo.com>
#               updates inspired by Guide tools extension by
#                   2009 Richard Querin <screencasters@heathenx.org>
#                   2009 heathenx <screencasters@heathenx.org>
#                   2014 Samuel Dellicour
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# Thanks to:
#
# Bernard Gray - bernard.gray **AT** gmail.com (python helping)
# Jamie Heames (english translation issues)
# ~suv (bug report in v2.3)
# http://www.gutenberg.eu.org/publications/ (9x9 margins settings)
#
"""
This extension allows you to automatically add guides to your Inkscape documents.
"""

from math import sqrt
import re
import types
import inkex
from inkex.elements import Guide

__version__ = 1.4

class GuidesCreator(inkex.EffectExtension):
    """Create a set of guides based on the given options"""

    def add_arguments(self, pars):
        # General options
        pars.add_argument('--tab', default='preset_guides',
                          help='Type of guides to create')
                          # options: preset_guides, margin_guides, grid_guides diagonal_guides, delete_selected
        pars.add_argument('--unit', default='mm', help='Units')
                          # options: mm, cm, in, px, pt, pc
        pars.add_argument('--start_from_edges',
                          type=inkex.Boolean,
                          help='Start from edges')
        pars.add_argument('--delete_existing',
                          type=inkex.Boolean,
                          help='Delete existing guides')
        pars.add_argument('--lock',
                          type=inkex.Boolean,
                          help='Lock newly added guides')
        pars.add_argument('--color', type=inkex.Color,
                          default=inkex.Color('#3f3fff20'),
                          help='Color of guide lines, as hex value with optional transparency, e.g. #3f3fff20')
        pars.add_argument('--label', default='',
                           help='Guide label text')
        pars.add_argument('--pages', default='',
                           help="Leave empty for all pages, or enter a number for a specific page (e.g. '2'), a range for multiple pages in a sequence (e.g. '1-10'), or a '+' for multiple pages that are not directly following one another (e.g. 4+7). Separate the instructions with a comma, e.g. '2,5-7,8+9'. Spaces will be ignored. Setting is ignored if something is selected, guides are added to the selection instead.")

        # Presets tab options
        pars.add_argument('--preset_option',
                          default='centered',
                          help='Create a preset type of guides, options: centered, golden, rule_of_third, book_left, book_right')    

        # Margin tab options
        pars.add_argument('--margin_type',
                          default='margins_by_distance',
                          help='Method for generating margin guides, options: margins_by_distance, margins_by_fraction')

        pars.add_argument('--same_margins',
                          type=inkex.Boolean,
                          help='Use top margin for all sides')

        ## Margins by distance
        pars.add_argument('--mbd_margin_top', type=float, default=10.0,
                          help='Top margin')
        pars.add_argument('--mbd_margin_bottom', type=float, default=10.0,
                          help='Bottom margin')
        pars.add_argument('--mbd_margin_left', type=float, default=10.0,
                          help='Left margin')
        pars.add_argument('--mbd_margin_right', type=float, default=10.0,
                          help='Right margin')
        ## Margins by fraction
        pars.add_argument('--mbf_dim', default='w', 
                          help="Use fraction of width (w) or height (h)")
        pars.add_argument('--mbf_margin_top', type=int,
                          choices=range(1, 11) , default=10,
                          help='Top margin is 1/value * document or selection width, a value of 1 means no guide.')
        pars.add_argument('--mbf_margin_bottom', type=int,
                          choices=range(1, 11) , default=10,
                          help='Bottom margin is 1/value * document or selection width, a value of 1 means no guide.')
        pars.add_argument('--mbf_margin_left', type=int,
                          choices=range(1, 11) , default=10,
                          help='Left margin is 1/value * document or selection height, a value of 1 means no guide.')
        pars.add_argument('--mbf_margin_right', type=int,
                          choices=range(1, 11) , default=10,
                          help='Right margin is 1/value * document or selection height, a value of 1 means no guide.')

        # Grid tab options
        pars.add_argument('--grid_type_tab', default="grid_even",
                          help="Type of grid to create, options: grid_even, grid_by_distance")

        ## Evenly spaced grid
        pars.add_argument('--ge_num_rows', type=int, default=3,
                          help='Number of rows to spread evenly')
        pars.add_argument('--ge_num_cols', type=int, default=2,
                          help='Number of columns to spread evenly')
        ## Grid by distance
        pars.add_argument('--report_dimensions', type=inkex.Boolean,
                          default=False, help="Open a popup dialog that reports total width and height of a grid that was specified by distances.")
        ### Rows
        pars.add_argument('--gbd_num_rows', type=int, default=3,
                          help='Number of rows with specified height')
        pars.add_argument('--gbd_row_height', type=float, default=50.0,
                          help='Row height')
        pars.add_argument('--gbd_row_gutter', type=float, default=10.0,
                          help='Spacing between rows')
        pars.add_argument('--gbd_include_outer_row_gutter', type=inkex.Boolean,
                          default=True,
                          help='Include outer row gutters')
        pars.add_argument('--gbd_row_align', default="top",
                          help='Row alignment in relation to the page or selection, options: top, centered, bottom')

        ### Columns
        pars.add_argument('--gbd_num_cols', type=int, default=2,
                          help='Number of columns with specified width')
        pars.add_argument('--gbd_col_width', type=float, default=50.0,
                          help='Column width')
        pars.add_argument('--gbd_col_gutter', type=float, default=10.0,
                          help='Spacing between columns')
        pars.add_argument('--gbd_include_outer_col_gutter', type=inkex.Boolean,
                          default=True,
                          help='Include outer column gutters')
        pars.add_argument('--gbd_col_align', default="left",
                          help='Column alignment in relation to the page or selection, options: left, centered, right')

        # Diagonal tab options
        pars.add_argument('--ul_to_lr', type=inkex.Boolean, default=True,
                          help='Upper left corner to lower right corner')
        pars.add_argument('--ur_to_ll', type=inkex.Boolean, default=True,
                          help='Upper right corner to lower left corner')
        pars.add_argument('--ul', type=inkex.Boolean,
                          help='Upper left corner (45°)')
        pars.add_argument('--ur', type=inkex.Boolean,
                          help='Upper right corner (45°)')
        pars.add_argument('--ll', type=inkex.Boolean,
                          help='Lower left corner (45°)')
        pars.add_argument('--lr', type=inkex.Boolean,
                          help='Lower right corner (45°)')

        # Delete tab options
        pars.add_argument('--remove_hor_guides', type=inkex.Boolean,
                          default=True,
                          help='Delete horizontal guides')
        pars.add_argument('--remove_vert_guides', type=inkex.Boolean,
                          default=True,
                          help='Delete vertical guides')
        pars.add_argument('--remove_ang_guides', type=inkex.Boolean,
                          default=True,
                          help='Delete angled guides')


    def effect(self):
        
        # only apply these settings when drawing new guides, 
        # not when deleting specific ones
        if self.options.tab != 'delete_selected':
            # delete all guides that were there before
            if self.options.delete_existing:
                for guide in self.svg.namedview.get_guides():
                    guide.delete()

        # Getting the width and height attributes of the canvas or selection
        # Sometimes retrieving the selection bounding box fails, e.g. when a
        # layer is selected. We use the page area in that case.
        if self.svg.selected and self.svg.selection.bounding_box() is not None:
            bbox = self.get_new_bounding_box(self.svg.selected.bounding_box())
            self.draw_guides(bbox)
        else:
            self.parse_pages()
            doc_pages = self.svg.namedview.get_pages()
            if len(doc_pages) == 0: # this means the document only has one page
                # get a copy of the bounding box
                bbox = self.get_new_bounding_box(self.svg.get_page_bbox())
                self.draw_guides(bbox)

            else:
                for g_page_num in self.g_pages:
                    g_page = doc_pages[g_page_num-1]
                    bbox = self.get_new_bounding_box(g_page)
                    self.draw_guides(bbox)
                    


    def draw_guides(self, bbox):

        tab_functions = {
            'preset_guides': self.create_preset_guides,
            'margin_guides': self.create_margin_guides,
            'grid_guides': self.create_grid_guides,
            'diagonal_guides': self.create_diagonal_guides,
            'delete_selected': self.delete_selected_guides
        }

        # use appropriate function for the selected tab
        tab_functions[self.options.tab](bbox)

        ul_corner = (bbox.left, bbox.top)
        ur_corner = (bbox.right, bbox.top)
        bl_corner = (bbox.left, bbox.bottom)
        br_corner = (bbox.right, bbox.bottom)

        # draw guides around the page / selection / generated grid
        # may change corner coordinates for some guides
        # do this last, so they won't be deleted
        if self.options.start_from_edges and self.options.tab != 'delete_selected':
            self.draw_guide(ul_corner, 'hor' ) # top edge
            self.draw_guide(br_corner, 'hor' ) # bottom edge
            self.draw_guide(bl_corner, 'vert' ) # left edge
            self.draw_guide(ur_corner, 'vert' ) # right edge


    # METHODS FOR EACH TAB
    # --------------------

    def create_preset_guides(self, bbox):
        """Generate a preset type of guides"""

        preset = self.options.preset_option

        if preset == 'golden':
            gold = (1 + sqrt(5)) / 2

            # horizontal golden guides
            position1 = (bbox.left, bbox.top + bbox.height / gold)
            position2 = (bbox.left, bbox.top + bbox.height - (bbox.height / gold))
            self.draw_guide(position1, 'hor')
            self.draw_guide(position2, 'hor')

            # vertical golden guides
            position1 = (bbox.left + bbox.width / gold, bbox.bottom)
            position2 = (bbox.left + bbox.width - (bbox.width / gold), bbox.bottom)
            self.draw_guide(position1, 'vert')
            self.draw_guide(position2, 'vert')

        elif preset == 'centered':
            self.divide_space(bbox, 2, vert=True)
            self.divide_space(bbox, 2, vert=False)

        elif preset == 'rule_of_third':
            self.divide_space(bbox, 3, vert=True)
            self.divide_space(bbox, 3, vert=False)

        elif preset.startswith('book_'):
            # 1/9th header
            y_header = bbox.top + (bbox.height / 9)
            self.draw_guide((bbox.left, y_header), 'hor')

            # 2/9th footer
            y_footer = bbox.top + (bbox.height / 9 * 7)
            self.draw_guide((bbox.left, y_footer), 'hor')

            if preset == 'book_left':
                # 2/9th left margin
                x_left = bbox.left + (bbox.width / 9 * 2)
                self.draw_guide((x_left, bbox.bottom), 'vert')

                # 1/9th right margin
                x_right = bbox.left + (bbox.width / 9 * 8)
                self.draw_guide((x_right, bbox.bottom), 'vert')

            elif preset == 'book_right':
                # 2/9th left margin
                x_left = bbox.left + (bbox.width / 9)
                self.draw_guide((x_left, bbox.bottom), 'vert')

                # 1/9th right margin
                x_right = bbox.left + (bbox.width / 9 * 7)
                self.draw_guide((x_right, bbox.bottom), 'vert')
        else:
            raise inkex.AbortExtension(
                "Unknown guide preset: {}".format(preset))

    def create_grid_guides(self, bbox):
        """Generate a grid of horizontal and vertical guides"""
        # Simple grid, specified only by number of rows and columns
        if self.options.grid_type_tab == "grid_even":
            self.divide_space(bbox, self.options.ge_num_rows, False)
            self.divide_space(bbox, self.options.ge_num_cols, True)

        # Complex grid, specified by distances, with numerous options
        elif self.options.grid_type_tab == "grid_by_distance":

            # Rows
            # ----
            row_height = self.svg.unittouu(str(self.options.gbd_row_height)
                                           + self.options.unit)
            gutter_height = self.svg.unittouu(
                                          str(self.options.gbd_row_gutter)
                                           + self.options.unit)

            total_height = (self.options.gbd_num_rows
                            * (row_height + gutter_height)
                           - gutter_height
                           + 2 * self.options.gbd_include_outer_row_gutter
                            * gutter_height)

            # How far do we need to shift the bounding box? This allows to draw
            # edge guides around the actual grid.
            row_alignment = {
                'top': bbox.height - total_height,
                'centered': (bbox.height - total_height)/2,
                'bottom': 0,
            }

            # update bounding box to shift grid position
            # (default is bottom left)
            if self.options.gbd_row_align in row_alignment:
                y1 = bbox.top - row_alignment[self.options.gbd_row_align]
                y2 = bbox.bottom - row_alignment[self.options.gbd_row_align]
                bbox = self.get_new_bounding_box(((bbox.left, bbox.right), (y1, y2)))

            # draw one side of gutter
            dist = row_height + gutter_height # same for all rows

            if self.options.gbd_include_outer_row_gutter and gutter_height != 0:
                num = self.options.gbd_num_rows
                shift = 0
            else:
                num = self.options.gbd_num_rows - 1
                shift = - 1 * gutter_height

            # draw bottom side of gutter / no gutter guides
            self._equidistant_guides(bbox, dist, num, shift=shift, vert=False)

            if gutter_height != 0:
                # we need an additional guide for the gutter
                if self.options.gbd_include_outer_row_gutter:
                    num = self.options.gbd_num_rows
                    shift = -1 * row_height
                else:
                    num = self.options.gbd_num_rows - 1
                    shift = 0

                # draw right side of gutter
                self._equidistant_guides(bbox, dist, num, shift=shift, vert=False)


            # Columns
            # -------
            col_width = self.svg.unittouu(str(self.options.gbd_col_width)
                                          + self.options.unit)
            gutter_width = self.svg.unittouu(
                                            str(self.options.gbd_col_gutter)
                                            + self.options.unit)
            total_width = (self.options.gbd_num_cols
                           * (col_width + gutter_width)
                          - gutter_width
                          + self.options.gbd_include_outer_col_gutter
                           * (2 * gutter_width))

            # How far do we need to shift the grid to align it correctly?
            col_alignment = {
                'left': 0,
                'centered': (bbox.width - total_width)/2,
                'right': bbox.width - total_width,
            }

            if self.options.gbd_col_align in col_alignment:
                x1 = bbox.left + col_alignment[self.options.gbd_col_align]
                x2 = bbox.right + col_alignment[self.options.gbd_col_align]

                bbox = self.get_new_bounding_box(((x1, x2), (bbox.top, bbox.bottom)))

            dist = col_width + gutter_width # same for all columns

            # draw one side of gutter
            if self.options.gbd_include_outer_col_gutter and gutter_width != 0:
                num = self.options.gbd_num_cols
                shift = 0
            else:
                num = self.options.gbd_num_cols - 1
                shift = - 1 * gutter_width

            # draw left side of gutter / no gutter guides
            self._equidistant_guides(bbox, dist, num, shift=shift, vert=True)

            if gutter_width != 0:
                # draw other side of gutter
                if self.options.gbd_include_outer_col_gutter:
                    num = self.options.gbd_num_cols
                    shift = -1 * col_width
                else:
                    num = self.options.gbd_num_cols - 1
                    shift = 0

                # draw right side of gutter
                self._equidistant_guides(bbox, dist, num, shift=shift, vert=True)

            if self.options.report_dimensions:
                inkex.errormsg("Width: " + str(self.svg.uutounit(total_width, self.options.unit)) + str(self.options.unit) +
                "\nHeight: " + str(self.svg.uutounit(total_height, self.options.unit)) + self.options.unit)

            # # update edge coordinates, so the grid will be 'closed'
            # # if the edge option is checked
            # self.bl_corner = (bbox.left, bbox.bottom)
            # self.ul_corner = (bbox.left, bbox.bottom - total_height)
            # self.ur_corner = (bbox.left + total_width,
            #                   bbox.bottom - total_height)
            # self.br_corner = (bbox.left + total_width, bbox.bottom)

    def create_margin_guides(self, bbox):
        """Generate margin guides"""

        if self.options.margin_type == 'margins_by_distance':

            if self.options.same_margins:
                self.options.mbd_margin_right = \
                self.options.mbd_margin_left = \
                self.options.mbd_margin_bottom = \
                self.options.mbd_margin_top

            # draw a guide at the left margin when we're not doing that already via start_from_edges option
            if not (self.options.mbd_margin_left == 0 and
                    self.options.start_from_edges == True):
                margin_left_x = bbox.left + self.svg.unittouu(
                                    str(self.options.mbd_margin_left) +
                                    self.options.unit)
                self.draw_guide((margin_left_x, bbox.bottom),
                                'vert')

            # same for right margin
            if not (self.options.mbd_margin_right == 0 and
                    self.options.start_from_edges == True):
                margin_right_x = bbox.right - self.svg.unittouu(
                                    str(self.options.mbd_margin_right) + self.options.unit)
                self.draw_guide((margin_right_x, bbox.bottom),
                                'vert')

            # for top margin
            if not (self.options.mbd_margin_top == 0 and
                    self.options.start_from_edges == True):
                margin_top_y = bbox.top + self.svg.unittouu(
                                    str(self.options.mbd_margin_top) + self.options.unit)
                self.draw_guide((bbox.left, margin_top_y),
                                'hor')

            # for bottom margin
            if not (self.options.mbd_margin_right == 0 and
                    self.options.start_from_edges == True):
                margin_bottom_y = bbox.bottom - self.svg.unittouu(
                                    str(self.options.mbd_margin_bottom) + self.options.unit)
                self.draw_guide((bbox.left, margin_bottom_y),
                                 'hor')

        elif self.options.margin_type == 'margins_by_fraction':

            guides = []

            if self.options.mbf_dim == 'w':
                dim = bbox.width
            else:
                dim = bbox.height

            if self.options.same_margins:
                self.options.mbf_margin_right = \
                self.options.mbf_margin_left = \
                self.options.mbf_margin_bottom = \
                self.options.mbf_margin_top

            if self.options.mbf_margin_right > 1:
                x = bbox.right - (dim / self.options.mbf_margin_right)
                y = bbox.bottom
                self.draw_guide((x,y), 'vert')

            if self.options.mbf_margin_left > 1:
                x = bbox.left + (dim / self.options.mbf_margin_left)
                y = bbox.bottom
                self.draw_guide((x,y), 'vert')

            if self.options.mbf_margin_bottom > 1:
                x = bbox.left
                y = bbox.bottom - (dim / self.options.mbf_margin_bottom)

                self.draw_guide((x,y), 'hor')

            if self.options.mbf_margin_top > 1:
                x = bbox.left
                y = bbox.top + (dim / self.options.mbf_margin_top)
                self.draw_guide((x,y), 'hor')

    def create_diagonal_guides(self, bbox):
        """Generate diagonal guides"""

        ul_corner = (bbox.left, bbox.top)
        ur_corner = (bbox.right, bbox.top)
        bl_corner = (bbox.left, bbox.bottom)
        br_corner = (bbox.right, bbox.bottom)

        # diagonal corner to corner
        if self.options.ul_to_lr:
            orientation = str(bbox.height) + ',' + str(bbox.width)
            self.draw_guide(ul_corner, orientation)

        if self.options.ur_to_ll:
            orientation = str(bbox.height) + ',-' + str(bbox.width)
            self.draw_guide(ur_corner, orientation)

        # 45° angle
        if self.options.ul:
            self.draw_guide(ul_corner, '1,1')

        if self.options.ur:
            self.draw_guide(ur_corner, '1,-1')

        if self.options.ll:
            self.draw_guide(bl_corner, '-1,1')

        if self.options.lr:
            self.draw_guide(br_corner, '1,1')

    def delete_selected_guides(self, bbox):
        """Delete specified guide types"""
        # bbox argument is only needed so it can be called like the other tabs

        for guide in self.svg.namedview.get_guides():
            if guide.is_horizontal and self.options.remove_hor_guides:
                guide.delete()
            elif guide.is_vertical and self.options.remove_vert_guides:
                guide.delete()
            elif not guide.is_vertical and not guide.is_horizontal and self.options.remove_ang_guides:
                guide.delete()

    # HELPER METHODS
    # --------------

    def parse_pages(self):
        g_pages = []
        self.num_pages = len(self.svg.namedview.get_pages()) or 1
        if self.options.pages.strip() == '':
            g_pages.extend(range(1,self.num_pages+1))
        else:
            inkex.utils.debug(self.options.pages)
            for snippet in self.options.pages.split(','):
                snippet.strip()
                snippet = re.sub('[^+-0123456789]', '', snippet)
                if re.match(r'[0-9]+\+([0-9]\+)*[0-9]+', snippet):
                    pgs = snippet.split('+')
                    g_pages.extend([int(n) for n in pgs])
                elif re.match('[0-9]+-[0-9]+', snippet):
                    a,b = snippet.split('-')
                    if a > b:
                        a,b = b,a
                    g_pages.extend(range(int(a), int(b)+1))
                elif re.match('[0-9]+', snippet):
                    g_pages.append(int(snippet))
                else:
                    inkex.errormsg('The pages list information could not be interpreted, please check the formatting (see tooltip)!')
        
        # Don't proceed if requested pages don't exist.
        g_pages = set(g_pages)
        for n in g_pages:
            if n > self.num_pages:
                raise inkex.AbortExtension("Page {} does not exist in the document, please check the pages range!\nNo guides were created.".format(str(n)))
        self.g_pages = g_pages

    def get_new_bounding_box(self, some_obj):
        """Creates a new bounding box from a tuple, Page or Bounding Box object"""
        if isinstance(some_obj, tuple):
            ((x1,x2),(y1,y2)) = some_obj
        elif isinstance(some_obj, inkex.elements._meta.Page):
            x1 = some_obj.x
            x2 = x1 + some_obj.width
            y1 = some_obj.y
            y2 = y1 + some_obj.height
        elif isinstance(some_obj, inkex.transforms.BoundingBox):
            x1 = some_obj.left
            x2 = some_obj.right
            y1 = some_obj.top
            y2 = some_obj.bottom

        return inkex.transforms.BoundingBox((x1, x2), (y1, y2))

    def divide_space(self, bbox, division, vert=False):
        """
        Divide the available space to num divisions by vertical or horizontal guides.

        division -- int > 1. Indicates the number of divisions (rows, columns).
        vert -- False for horizontal guides, True for vertical guides.
        """
        if division <= 1:
            # Don't draw any guides,
            # this makes it possible to draw only rows or only columns.
            return

        if vert:
            distance = bbox.width / division
        else:
            distance = bbox.height / division

        return self._equidistant_guides(bbox, distance, division - 1, vert=vert)

    def _equidistant_guides(self, bbox, distance, num_guides, shift=0, vert=False):

        for i in range(num_guides):
            if vert:
                orientation = 'vert'
                x = bbox.left + round(distance + (i) * distance + shift, 4)
                y = bbox.bottom
            else:
            # horizontal
                orientation = 'hor'
                x = bbox.left
                y = bbox.bottom - round(distance + (i) * distance + shift, 4)

            self.draw_guide((x, y), orientation)

    def draw_guide(self, position, orientation):
        """
        Create a guide directly into the namedview

        position -- tuple of x and y coordinates of guide anchor
        orientation -- orientation vector tuple, or shorthand 'vert' or 'hor'
        """

        x, y = position
        if orientation == "vert":
            orientation = (1, 0)
        elif orientation == "hor":
            orientation = (0, 1)

        v = inkex.__version__.split('.')
        if v[0] == '1' and v[1] < '3':
            # fix for borked guide coordinates for Inkscape < 1.3, 
            # because Inkscape and inkex use wrong coordinates 
            # that are relative to the document height
            y = -y + self.svg.get_page_bbox().height
            new_guide = Guide().move_to(x, y, orientation)

        else: # from Inkscape 1.3 on
            new_guide = self.svg.namedview.add_guide((x, y), orientation)
        
        # We would use the new_unique_guide() method if that returned a guide even if it already exists - because we need to set a new color and label.
        to_remove = []
        for guide in self.svg.namedview.get_guides():
            if Guide.guides_coincident(guide, new_guide):
                to_remove.append(guide)
        for guide in to_remove:
            guide.delete()
        if self.options.label != '':
            new_guide.set('inkscape:label', self.options.label)
        if self.options.lock:
            new_guide.set('inkscape:locked', 'true')
        new_guide.set('inkscape:color', self.options.color)
        self.svg.namedview.add(new_guide)


if __name__ == '__main__':
    GuidesCreator().run()
