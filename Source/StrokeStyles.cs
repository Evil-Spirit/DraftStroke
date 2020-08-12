﻿using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

namespace EvilSpirit
{
    [System.Serializable]
    public class StrokeStyle
    {
        public string name = System.Guid.NewGuid().ToString();
        public float width = 1f;

        public double scale(double pixelSize)
        {
            return (inPixels) ? 1.0 : 1.0 / pixelSize;
        }

        public double dashesScale(double pixelSize)
        {
            return (dashesInPixels) ? 1.0 : 1.0 / pixelSize;
        }

        public double scaleMm(double pixelSize)
        {
            return (inPixels) ? pixelSize : 1.0;
        }

        public double dashesScaleMm(double pixelSize)
        {
            return (dashesInPixels) ? pixelSize : 1.0;
        }

        public bool depthTest = true;

        public bool inPixels = true;

        public bool dashesInPixels = true;

        public int queue = 2002;

        public Color color = Color.white;
        public float[] dashes = new float[0];

        public StrokeStyle WithWidthAndStippleFrom(StrokeStyle takeWidthAndStipple)
        {
            return new StrokeStyle
            {
                name = name + "_" + takeWidthAndStipple.name,
                width = takeWidthAndStipple.width,
                inPixels = takeWidthAndStipple.inPixels,
                dashesInPixels = takeWidthAndStipple.dashesInPixels,
                depthTest = depthTest,
                queue = queue,
                color = color,
                dashes = takeWidthAndStipple.dashes
            };
        }

        public void Set(StrokeStyle style)
        {
            name = style.name;
            width = style.width;
            //stippleWidth = style.stippleWidth;
            depthTest = style.depthTest;
            inPixels = style.inPixels;
            dashesInPixels = style.dashesInPixels;
            queue = style.queue;
            color = style.color;
            dashes = style.dashes;
        }

        public static bool operator ==(StrokeStyle a, StrokeStyle b)
        {
            if (object.ReferenceEquals(a, b)) return true;
			if(object.ReferenceEquals(a, null) || object.ReferenceEquals(b, null)) return false;
            return
                a.width == b.width &&
                //a.stippleWidth == b.stippleWidth &&
                a.depthTest == b.depthTest &&
                a.inPixels == b.inPixels &&
                a.dashesInPixels == b.dashesInPixels &&
                a.queue == b.queue &&
                a.color == b.color &&
                a.dashes.SequenceEqual(b.dashes);
        }

        public override bool Equals(object obj)
        {
            return this == (StrokeStyle)obj;
        }

        public static bool operator !=(StrokeStyle a, StrokeStyle b)
        {
            if (object.ReferenceEquals(a, b)) return false;
            return !(a == b);
        }

        public static bool operator <(StrokeStyle a, StrokeStyle b)
        {
            if (a.width != b.width) return a.width < b.width;
            //if(a.stippleWidth != b.stippleWidth) return a.stippleWidth < b.stippleWidth;
            if (a.depthTest != b.depthTest) return a.depthTest == false;
            if (a.inPixels != b.inPixels) return a.inPixels == false;
            if (a.dashesInPixels != b.dashesInPixels) return a.dashesInPixels == false;
            if (a.queue != b.queue) return a.queue < b.queue;
            if (a.color.r != b.color.r) return a.color.r < b.color.r;
            if (a.color.g != b.color.g) return a.color.g < b.color.g;
            if (a.color.b != b.color.b) return a.color.b < b.color.b;
            if (!a.dashes.SequenceEqual(b.dashes))
            {
                if (a.dashes.Length != b.dashes.Length) return a.dashes.Length < b.dashes.Length;
                for (int i = 0; i < a.dashes.Length; i++)
                {
                    if (a.dashes[i] != b.dashes[i]) return a.dashes[i] < b.dashes[i];
                }
            }
            return false;
        }

        public static bool operator >(StrokeStyle a, StrokeStyle b)
        {
            return b < a;
        }

        static public float GetPatternLength(float[] pattern)
        {
            if (pattern == null) return 0f;
            float patternLen = 0f;
            foreach (var s in pattern)
            {
                patternLen += s;
            }
            return patternLen;
        }

        public float GetPatternLength()
        {
            var result = GetPatternLength(dashes);
            if (result == 0f) return 1f;
            return result;
        }

        public override int GetHashCode()
        {
            return name.GetHashCode();
        }

    }

    public class StrokeStyles : MonoBehaviour
    {
        public StrokeStyle[] styles = new StrokeStyle[0];
    }
}