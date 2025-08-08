/*
 Copyright (C) AC SOFTWARE SP. Z O.O.

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */
    
@inline(__always) func cancelableTaskWithTimeout<T>(timeout: UInt64, task: @escaping () async -> T) async -> T? {
    let mainTask = Task {
        let result = await task()
        try Task.checkCancellation()
        return result
    }
    
    let timeoutTask = Task {
        try await Task.sleep(nanoseconds: timeout * NSEC_PER_SEC)
        SALog.debug("Timeout reached - canceling task")
        mainTask.cancel()
    }
    
    do {
        let result = try await withTaskCancellationHandler {
            try await mainTask.value
        } onCancel: {
            SALog.debug("Cancelable task canceled")
            mainTask.cancel()
            timeoutTask.cancel()
        }
        timeoutTask.cancel()
        return result
    } catch {
        SALog.error("Cancelable task end up with timeout")
        return nil
    }
}
