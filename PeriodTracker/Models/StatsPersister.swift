//
//  StatsPersister.swift
//  PeriodTracker
//
//  Created by open-analysis
//

import Foundation
import SwiftData

/// Debounced persister for updating Stats objects safely off of the calendar render path.
/// Usage: compute new prevDurations/outliers in-memory, then call:
/// StatsPersister.shared.schedulePersist(prevDurations:..., outliers:..., durationStats:..., modelContext: context)
final class StatsPersister {
    static let shared = StatsPersister()
    
    // Task that will perform the scheduled write. We cancel/reschedule when a new request arrives.
    private var scheduledTask: Task<Void, Never>?
    private let debounceNanoseconds: UInt64 = 300_000_000 // 300ms
    
    private init() {}
    
    /// Schedule persistence of prevDurations and outliers. Debounced to avoid write loops.
    /// This method is safe to call from the main actor; the actual writes happen on the main actor
    /// after the debounce delay to avoid re-entrant writes during rendering.
    func schedulePersist(prevDuration: TimeInterval,
                         outliers: [Event: Int],
                         durationStats: [Stats],
                         modelContext: ModelContext) {
        // Cancel prior pending persistence and schedule a new one
        scheduledTask?.cancel()
        scheduledTask = Task { [prevDuration, outliers, durationStats, modelContext] in
            // Debounce delay
            try? await Task.sleep(nanoseconds: debounceNanoseconds)
            // If the task was canceled during sleep, stop early
            if Task.isCancelled { return }
            
            // Now perform writes on the main actor (ModelContext must be used on main actor)
            await MainActor.run {
                // Apply prevDurations to durationStats (mutate existing Stats objects)
                let statType = "menstrual-duration"
                for stat in durationStats {
                    if stat.type == statType {
                        stat.value = prevDuration
                    }
                }
                
                // If there are outliers we might want to update outlier stats.
                // For now, keep the existing outlier-stat handling in StatsListView / other UI,
                // or add insertion logic here if desired (keeping it debounced).
                // NOTE: do not perform a large op here without considering performance.
                // An alternative is to mark a "needsOutlierPersist" flag and do minimal writes.
                
                // Save is implicit with SwiftData's ModelContext; no explicit save call is available.
            }
        }
    }
}
