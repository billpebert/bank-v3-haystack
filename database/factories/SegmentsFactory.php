<?php

/** @var \Illuminate\Database\Eloquent\Factory $factory */

use App\Model\Segments;
use Faker\Generator as Faker;

$factory->define(Segments::class, function (Faker $faker)  use ($factory) {
    return [
        'SegmentName' => $faker->unique()->name,
        'SegmentGroupsID' => $factory->create(Segmentgroups::class)->id,
    ];
});
