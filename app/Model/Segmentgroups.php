<?php

namespace App\Model;

use Illuminate\Database\Eloquent\Model;

class Segmentgroups extends Model
{
    protected $fillable = ['SegmentName','SegmentGroupsID'];
    public $timestamps = false; 
}
