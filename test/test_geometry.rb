$: << 'lib'
require File.join(File.dirname(__FILE__), '..', 'lib', 'OSM', 'objects.rb')
require 'test/unit'
require 'rubygems'
require 'geo_ruby'

class GeometryTest < Test::Unit::TestCase

    def setup
        @db = OSM::Database.new
    end

    def test_node_geometry
        node = OSM::Node.new(1, nil, nil, 10.4, 40.3)
        assert_kind_of GeoRuby::SimpleFeatures::Point, node.geometry
        assert_equal 10.4, node.geometry.lon
        assert_equal 40.3, node.geometry.lat
    end

    def test_node_geometry_nil
        node = OSM::Node.new(1)
        assert_kind_of GeoRuby::SimpleFeatures::Point, node.geometry
        assert_equal 0.0, node.geometry.lon
        assert_equal 0.0, node.geometry.lat
    end

    def test_node_shape
        node = OSM::Node.new(1, nil, nil, 10.4, 40.3)
        attrs = {'a' => 'b', 'c' => 'd'}
        shape = node.shape(attrs)
        assert_kind_of GeoRuby::Shp4r::ShpRecord, shape
        assert_equal attrs, shape.data
        assert_kind_of GeoRuby::SimpleFeatures::Point, shape.geometry
        assert_equal node.geometry, shape.geometry
    end

    def test_way_geometry_nil
        way = OSM::Way.new(1)
        assert_nil way.linestring
        assert_nil way.polygon
        assert_nil way.geometry
    end

    def test_way_geometry_fail
        way = OSM::Way.new(1)
        way.nodes << OSM::Node.new.id << OSM::Node.new.id << OSM::Node.new.id
        assert_raise OSM::NoDatabaseError do
            way.linestring
        end
        assert_raise OSM::NoDatabaseError do
            way.polygon
        end
        assert_raise OSM::NoDatabaseError do
            way.geometry
        end
    end

    def test_way_geometry
        @db << (way = OSM::Way.new(1))
        @db << (node1 = OSM::Node.new(nil, nil, nil, 0, 0))
        @db << (node2 = OSM::Node.new(nil, nil, nil, 0, 10))
        @db << (node3 = OSM::Node.new(nil, nil, nil, 10, 10))

        assert_nil way.linestring
        assert_nil way.polygon
        assert_nil way.geometry

        way.nodes << node1.id

        assert_nil way.linestring
        assert_nil way.polygon
        assert_nil way.geometry

        way.nodes << node2.id

        assert_kind_of GeoRuby::SimpleFeatures::LineString, way.linestring
        assert_nil way.polygon
        assert_kind_of GeoRuby::SimpleFeatures::LineString, way.geometry

        way.nodes << node3.id

        assert_kind_of GeoRuby::SimpleFeatures::LineString, way.linestring
        assert_raise OSM::NotClosedError do
            way.polygon
        end
        assert_kind_of GeoRuby::SimpleFeatures::LineString, way.geometry

        way.nodes << node1.id
        assert_kind_of GeoRuby::SimpleFeatures::Polygon, way.polygon

    end

end